function analyze_sequence(base_url, sequence_map)
{

    var allele_selected = $('.allele_checkbox:checked').val();

    var tokens = allele_selected.split(":");
    var $name = tokens[0];
    var $type = tokens[1];
    var $seq;
    var loci_tokens;

    tokens = sequence_map.split(/[=:]+/);

    //get the sequence we want to analyze
    for (var i = 0; i < tokens.length; i++)
    {

        if(tokens[i] == $name)
        {
            $seq = tokens[i+1];
            i = i+1;
        }

    }

    window.location.href = base_url +  "/" + $seq + "/" + $name+  "/" + $type ;

}
