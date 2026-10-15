
public class Parser.LRC : Object {
    private Lyrics.Lyric lyric;
    ChainOfResponsability parse_chain;

    public LRC () {
        parse_chain = new LyricEmptyStringParser ();
        parse_chain.add_parser_to_chain (new LyricMetadataParser ());
        parse_chain.add_parser_to_chain (new CompressedLyricContentParser ());
        parse_chain.add_parser_to_chain (new LyricContentParser ());
    }

    public Lyrics.Lyric parse (File file) {
        lyric = new Lyrics.Lyric ();
        try {
            DataInputStream dis = new DataInputStream (file.read ());
            string? ln;

            //  read_until consumes the "[" so there is no read_byte () past the end of the file
            while ((ln = dis.read_until ("[", null)) != null) {
                if ((ln = ln.strip ()) != "") {
                    debug ("Parsing line: [" + ln);
                    parse_chain.parse (lyric, "[" + ln);
                }
            }
        } catch (Error e) {
            warning (e.message);
        }
        return lyric;
    }

    public Lyrics.Lyric parse_string (string lrc) {
        lyric = new Lyrics.Lyric ();

        foreach (var ln in lrc.split ("\n")) {
            parse_chain.parse (lyric, ln.strip ());
        }

        return lyric;
    }
}
