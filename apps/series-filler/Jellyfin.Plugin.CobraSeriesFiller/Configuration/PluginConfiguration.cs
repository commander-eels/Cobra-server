using MediaBrowser.Model.Plugins;

namespace Jellyfin.Plugin.CobraSeriesFiller.Configuration;

/// <summary>
/// Settings shown on the plugin's page in the Jellyfin dashboard.
/// </summary>
public class PluginConfiguration : BasePluginConfiguration
{
    /// <summary>Gets or sets the folder of filler clips, as the Jellyfin container sees it.</summary>
    public string FillerFolder { get; set; } = "/media/wd1/filler";

    /// <summary>Gets or sets a value indicating whether clips in subfolders count too.</summary>
    public bool IncludeSubfolders { get; set; } = true;

    /// <summary>Gets or sets the fewest clips to play before an episode.</summary>
    public int MinClips { get; set; } = 1;

    /// <summary>Gets or sets the most clips to play before an episode.</summary>
    public int MaxClips { get; set; } = 3;

    /// <summary>Gets or sets the chance, 0-100, that an episode gets filler at all.</summary>
    public int ChancePercent { get; set; } = 100;

    /// <summary>Gets or sets a tag; a show, season or episode with this tag gets no filler.</summary>
    public string SkipTag { get; set; } = "nofiller";

    /// <summary>Gets or sets how many recent clips to avoid repeating.</summary>
    public int AvoidRecent { get; set; } = 10;
}
