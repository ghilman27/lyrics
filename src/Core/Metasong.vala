
public class Lyrics.Metasong : Object {
    public string artist { get; set; }
    public string title { get; set; }
    public string genre { get; set; }
    public string album { get; set; }
    public int64 duration { get; set; }
    public string uri  { get; set; }
    public string? path  { get; set; }
    public string filename  { get; set; }
    public string thumb  { get; set; }

    public Metasong.from_metadata (HashTable<string,Variant> metadata) {
        artist = get_strv_as_string (metadata["xesam:artist"]);
        title = get_string_or_null (metadata["xesam:title"]);
        genre = get_strv_as_string (metadata["xesam:genre"]);
        album = get_string_or_null (metadata["xesam:album"]);
        uri = get_string_or_null (metadata["xesam:url"]);

        //  MPRIS says int64 ("x"), but some players send uint64 ("t") or int32 ("i")
        var length = metadata["mpris:length"];
        if (length != null) {
            if (length.is_of_type (VariantType.INT64)) {
                duration = length.get_int64 ();
            } else if (length.is_of_type (VariantType.UINT64)) {
                duration = (int64) length.get_uint64 ();
            } else if (length.is_of_type (VariantType.INT32)) {
                duration = length.get_int32 ();
            }
        }

        filename = @"$(artist ?? "") - $(album ?? "") - $(title ?? "").lrc";

        var art_url = get_string_or_null (metadata["mpris:artUrl"]);
        if (art_url != null) {
            thumb = File.parse_name (art_url).get_path ();
        }
    }

    static string? get_string_or_null (Variant? value) {
        if (value == null || !value.is_of_type (VariantType.STRING)) {
            return null;
        }

        return value.get_string ();
    }

    //  Some players send a single string instead of the string array MPRIS asks for
    static string? get_strv_as_string (Variant? value) {
        if (value == null) {
            return null;
        }

        if (value.is_of_type (VariantType.STRING_ARRAY)) {
            return string.joinv (", ", value.get_strv ());
        }

        return get_string_or_null (value);
    }

    public string to_string () {
        var builder = new StringBuilder ();
        if (artist != null) builder.append (@"Artist: $artist\n");
        if (title != null) builder.append (@"Title: $title\n");
        if (album != null) builder.append (@"Album: $album\n");
        builder.append (@"Duration: $duration\n");
        if (uri != null) builder.append (@"URI: $uri\n");
        if (path != null) builder.append (@"Path: $path\n");
        if (filename != null) builder.append (@"Filename: $filename\n");
        return builder.str;
    }
}
