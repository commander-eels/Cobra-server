using System;
using System.IO;
using System.Linq;
using Jellyfin.Plugin.CobraSeriesFiller;
using Xunit;

namespace CobraSeriesFiller.Tests;

public class FillerPickerTests
{
    private static readonly string[] Five = { "/f/a.mp4", "/f/b.mp4", "/f/c.mp4", "/f/d.mp4", "/f/e.mp4" };

    [Fact]
    public void HowMany_StaysBetweenMinAndMax()
    {
        var picker = new FillerPicker(new Random(1));
        var counts = Enumerable.Range(0, 500).Select(_ => picker.HowMany(1, 3, 100)).ToList();
        Assert.All(counts, c => Assert.InRange(c, 1, 3));
        Assert.Contains(1, counts);
        Assert.Contains(3, counts);
    }

    [Fact]
    public void HowMany_FixesBadSettings()
    {
        var picker = new FillerPicker(new Random(1));
        Assert.Equal(2, picker.HowMany(2, 1, 100));
        Assert.Equal(0, picker.HowMany(-5, -1, 100));
        Assert.Equal(10, picker.HowMany(50, 99, 100));
    }

    [Fact]
    public void HowMany_ZeroChanceMeansNoFiller()
    {
        var picker = new FillerPicker(new Random(1));
        Assert.All(Enumerable.Range(0, 100), _ => Assert.Equal(0, picker.HowMany(1, 3, 0)));
    }

    [Fact]
    public void Pick_GivesDifferentClips()
    {
        var picker = new FillerPicker(new Random(2));
        var picked = picker.Pick(Five, 3, 0);
        Assert.Equal(3, picked.Count);
        Assert.Equal(3, picked.Distinct().Count());
    }

    [Fact]
    public void Pick_NeverMoreThanThereAre()
    {
        var picker = new FillerPicker(new Random(2));
        Assert.Equal(2, picker.Pick(new[] { "/f/a.mp4", "/f/b.mp4" }, 3, 10).Count);
        Assert.Empty(picker.Pick(Array.Empty<string>(), 3, 10));
    }

    [Fact]
    public void Pick_AvoidsRecentWhileItCan()
    {
        var picker = new FillerPicker(new Random(3));
        var first = picker.Pick(Five, 2, 2);
        var second = picker.Pick(Five, 2, 2);
        Assert.Empty(first.Intersect(second));
    }

    [Fact]
    public void ListClips_SkipsHiddenAndNonVideo()
    {
        var dir = Directory.CreateTempSubdirectory("csf");
        try
        {
            File.WriteAllText(Path.Combine(dir.FullName, "ad1.mp4"), "x");
            File.WriteAllText(Path.Combine(dir.FullName, "notes.txt"), "x");
            Directory.CreateDirectory(Path.Combine(dir.FullName, "psa"));
            File.WriteAllText(Path.Combine(dir.FullName, "psa", "psa1.MKV"), "x");
            Directory.CreateDirectory(Path.Combine(dir.FullName, ".trash"));
            File.WriteAllText(Path.Combine(dir.FullName, ".trash", "old.mp4"), "x");

            var all = FillerPicker.ListClips(dir.FullName, true).Select(Path.GetFileName).ToList();
            Assert.Equal(new[] { "ad1.mp4", "psa1.MKV" }, all);

            var top = FillerPicker.ListClips(dir.FullName, false).Select(Path.GetFileName).ToList();
            Assert.Equal(new[] { "ad1.mp4" }, top);

            Assert.Empty(FillerPicker.ListClips(Path.Combine(dir.FullName, "missing"), true));
        }
        finally
        {
            dir.Delete(true);
        }
    }
}
