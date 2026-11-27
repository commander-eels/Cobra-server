using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Jellyfin.Database.Implementations.Entities;
using MediaBrowser.Controller.Entities;
using MediaBrowser.Controller.Entities.TV;
using MediaBrowser.Controller.Library;
using Microsoft.Extensions.Logging;

namespace Jellyfin.Plugin.CobraSeriesFiller;

/// <summary>
/// Answers Jellyfin's "intros for this item?" question, for TV episodes only.
/// Jellyfin asks every intro provider, so Local Intros keeps handling movies.
/// </summary>
public class SeriesFillerIntroProvider : IIntroProvider
{
    /// <summary>Provider id stored on the clip items this plugin registers.</summary>
    internal const string ProviderKey = "CobraSeriesFiller";

    private static readonly FillerPicker Picker = new();
    private static readonly object CreateLock = new();

    private readonly ILibraryManager _libraryManager;
    private readonly ILogger<SeriesFillerIntroProvider> _logger;

    /// <summary>
    /// Initializes a new instance of the <see cref="SeriesFillerIntroProvider"/> class.
    /// </summary>
    /// <param name="libraryManager">Jellyfin's library manager.</param>
    /// <param name="logger">Logger.</param>
    public SeriesFillerIntroProvider(ILibraryManager libraryManager, ILogger<SeriesFillerIntroProvider> logger)
    {
        _libraryManager = libraryManager;
        _logger = logger;
    }

    /// <inheritdoc />
    public string Name => "Cobra Series Filler";

    /// <inheritdoc />
    public Task<IEnumerable<IntroInfo>> GetIntros(BaseItem item, User user)
    {
        try
        {
            return Task.FromResult(GetIntrosCore(item, user));
        }
        catch (Exception ex)
        {
            // Never break playback: on any problem the episode just starts without filler.
            _logger.LogError(ex, "[CobraSeriesFiller] Could not pick filler for '{Name}'", item?.Name);
            return Task.FromResult(Enumerable.Empty<IntroInfo>());
        }
    }

    private IEnumerable<IntroInfo> GetIntrosCore(BaseItem item, User user)
    {
        if (item is not Episode episode)
        {
            return Enumerable.Empty<IntroInfo>();
        }

        var config = Plugin.Instance?.Configuration;
        if (config is null)
        {
            return Enumerable.Empty<IntroInfo>();
        }

        if (HasSkipTag(episode, config.SkipTag))
        {
            _logger.LogInformation("[CobraSeriesFiller] '{Show}' {Ep}: tagged '{Tag}', no filler", episode.SeriesName, episode.Name, config.SkipTag);
            return Enumerable.Empty<IntroInfo>();
        }

        var count = Picker.HowMany(config.MinClips, config.MaxClips, config.ChancePercent);
        if (count == 0)
        {
            return Enumerable.Empty<IntroInfo>();
        }

        var clips = FillerPicker.ListClips(config.FillerFolder, config.IncludeSubfolders);
        if (clips.Count == 0)
        {
            _logger.LogWarning("[CobraSeriesFiller] No video files in '{Folder}'. Check the folder on the plugin's settings page.", config.FillerFolder);
            return Enumerable.Empty<IntroInfo>();
        }

        var picked = Picker.Pick(clips, count, config.AvoidRecent);
        var result = new List<IntroInfo>(picked.Count);
        foreach (var path in picked)
        {
            var clip = GetOrCreateClipItem(path);
            if (clip is not null)
            {
                result.Add(new IntroInfo { ItemId = clip.Id, Path = clip.Path });
            }
        }

        _logger.LogInformation(
            "[CobraSeriesFiller] {User} -> '{Show}' {Ep}: {Clips}",
            user?.Username ?? "?",
            episode.SeriesName,
            episode.Name,
            string.Join(", ", picked.Select(Path.GetFileName)));

        return result;
    }

    private static bool HasSkipTag(Episode episode, string skipTag)
    {
        if (string.IsNullOrWhiteSpace(skipTag))
        {
            return false;
        }

        IEnumerable<string> tags = episode.Tags ?? Array.Empty<string>();
        if (episode.Season?.Tags is { } seasonTags)
        {
            tags = tags.Concat(seasonTags);
        }

        if (episode.Series?.Tags is { } seriesTags)
        {
            tags = tags.Concat(seriesTags);
        }

        return tags.Any(t => string.Equals(t, skipTag.Trim(), StringComparison.OrdinalIgnoreCase));
    }

    /// <summary>
    /// Jellyfin plays intros by item id, so each clip needs an item in the database.
    /// The id is derived from the path, so the same file always gets the same item.
    /// </summary>
    private BaseItem? GetOrCreateClipItem(string path)
    {
        var id = _libraryManager.GetNewItemId(ProviderKey + ":" + path, typeof(Video));
        lock (CreateLock)
        {
            if (_libraryManager.GetItemById(id) is { } existing)
            {
                return existing;
            }

            var video = new Video
            {
                Id = id,
                Path = path,
                Name = Path.GetFileNameWithoutExtension(path).Replace('_', ' ').Trim(),
                OfficialRating = "G",
                ProviderIds = new Dictionary<string, string> { { ProviderKey, path } },
            };

            try
            {
                _libraryManager.CreateItem(video, null);
                _logger.LogInformation("[CobraSeriesFiller] Registered clip '{Path}'", path);
                return video;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[CobraSeriesFiller] Could not register clip '{Path}'", path);
                return null;
            }
        }
    }
}
