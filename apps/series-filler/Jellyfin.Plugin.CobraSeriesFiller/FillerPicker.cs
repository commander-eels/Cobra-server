using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace Jellyfin.Plugin.CobraSeriesFiller;

/// <summary>
/// Pure picking logic, kept free of Jellyfin types so it can be unit tested.
/// </summary>
internal sealed class FillerPicker
{
    /// <summary>File extensions treated as video clips.</summary>
    internal static readonly HashSet<string> VideoExtensions = new(StringComparer.OrdinalIgnoreCase)
    {
        ".mp4", ".m4v", ".mkv", ".mov", ".avi", ".webm", ".ts", ".m2ts", ".wmv", ".mpg", ".mpeg", ".flv", ".3gp",
    };

    private readonly object _lock = new();
    private readonly LinkedList<string> _recent = new();
    private readonly Random _random;

    /// <summary>
    /// Initializes a new instance of the <see cref="FillerPicker"/> class.
    /// </summary>
    /// <param name="random">Random source; pass a seeded one in tests.</param>
    public FillerPicker(Random? random = null)
    {
        _random = random ?? new Random();
    }

    /// <summary>
    /// Lists the video files in a folder. Hidden files and folders (names starting with a dot) are skipped.
    /// </summary>
    /// <param name="folder">The folder to read.</param>
    /// <param name="includeSubfolders">Whether to look in subfolders too.</param>
    /// <returns>Full paths, sorted, or an empty list when the folder is missing.</returns>
    public static IReadOnlyList<string> ListClips(string folder, bool includeSubfolders)
    {
        if (string.IsNullOrWhiteSpace(folder) || !Directory.Exists(folder))
        {
            return Array.Empty<string>();
        }

        return Directory.EnumerateFiles(folder, "*", new EnumerationOptions
            {
                RecurseSubdirectories = includeSubfolders,
                IgnoreInaccessible = true,
                AttributesToSkip = FileAttributes.Hidden | FileAttributes.System,
            })
            .Where(p => VideoExtensions.Contains(Path.GetExtension(p)))
            .Where(p => !Path.GetRelativePath(folder, p).Split(Path.DirectorySeparatorChar).Any(s => s.StartsWith('.')))
            .OrderBy(p => p, StringComparer.Ordinal)
            .ToList();
    }

    /// <summary>
    /// Decides how many clips to play: 0 when the chance roll fails, else a random number from min to max.
    /// Bad settings are fixed up: negative becomes 0, max below min becomes min, nothing above 10.
    /// </summary>
    /// <param name="min">Fewest clips.</param>
    /// <param name="max">Most clips.</param>
    /// <param name="chancePercent">Chance, 0-100, that any filler plays.</param>
    /// <returns>The number of clips to play.</returns>
    public int HowMany(int min, int max, int chancePercent)
    {
        min = Math.Clamp(min, 0, 10);
        max = Math.Clamp(Math.Max(max, min), 0, 10);
        chancePercent = Math.Clamp(chancePercent, 0, 100);
        lock (_lock)
        {
            if (chancePercent < 100 && _random.Next(100) >= chancePercent)
            {
                return 0;
            }

            return _random.Next(min, max + 1);
        }
    }

    /// <summary>
    /// Picks <paramref name="count"/> different clips at random, avoiding the most recent picks while
    /// there are enough other clips, and remembers what it picked.
    /// </summary>
    /// <param name="clips">All available clips.</param>
    /// <param name="count">How many to pick.</param>
    /// <param name="avoidRecent">How many recent picks to avoid.</param>
    /// <returns>The picked clips, in play order.</returns>
    public IReadOnlyList<string> Pick(IReadOnlyList<string> clips, int count, int avoidRecent)
    {
        if (clips.Count == 0 || count <= 0)
        {
            return Array.Empty<string>();
        }

        count = Math.Min(count, clips.Count);
        avoidRecent = Math.Clamp(avoidRecent, 0, 1000);

        lock (_lock)
        {
            var recent = new HashSet<string>(_recent, StringComparer.Ordinal);
            var fresh = clips.Where(c => !recent.Contains(c)).ToList();
            var stale = clips.Where(c => recent.Contains(c)).ToList();

            var picked = new List<string>(count);
            Shuffle(fresh);
            picked.AddRange(fresh.Take(count));

            if (picked.Count < count)
            {
                // Not enough fresh clips: reuse the oldest recent ones first.
                var oldestFirst = _recent.Reverse().Where(stale.Contains).ToList();
                picked.AddRange(oldestFirst.Take(count - picked.Count));
            }

            foreach (var p in picked)
            {
                _recent.Remove(p);
                _recent.AddFirst(p);
            }

            while (_recent.Count > avoidRecent)
            {
                _recent.RemoveLast();
            }

            return picked;
        }
    }

    private void Shuffle(List<string> list)
    {
        for (var i = list.Count - 1; i > 0; i--)
        {
            var j = _random.Next(i + 1);
            (list[i], list[j]) = (list[j], list[i]);
        }
    }
}
