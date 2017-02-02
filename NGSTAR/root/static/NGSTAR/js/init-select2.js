function matchStart (term, text)
{

    if(text.toUpperCase().indexOf(term.toUpperCase()) == 0)
    {
      return true;
    }

    return false;

  }

  $.fn.select2.amd.require(['select2/compat/matcher'], function (oldMatcher)
  {

    if($curr_lang == "en")
    {
        $("select").select2(
        {
          placeholder:"---Select---",
          matcher: oldMatcher(matchStart)
        });
    }
    else
    {
        $("select").select2(
        {
          placeholder:"---Sélectionnez---",
          matcher: oldMatcher(matchStart)
        });
    }
  });
