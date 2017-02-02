$(document).ready(function()
{

	$('#type_list').removeClass('hidden').addClass("in");
	$('#batch_st_query_table').removeClass('hidden').addClass("in");


	var $url_to_lang_file;

	if($curr_lang === "fr")
	{
		$url_to_lang_file = "/static/jquery-datatables/French.json";
	}

	var table = $('#type_list').dataTable({"aLengthMenu": [[5, 10, 25, -1], [5, 10, 25, "All"]], "iDisplayLength":10, "bAutoWidth": false, "sPaginationType": "full_numbers",  "bStateSave": true,
		"stateSaveParams": function (settings, data) {

			localStorage.setItem('curr_url', window.location.pathname);

			localStorage.setItem('pg_num',Math.ceil( settings._iDisplayStart / settings._iDisplayLength) + 1);
			localStorage.setItem('disp_len', settings._iDisplayLength);

		},
		"stateLoadParams": function (settings, data) {

			if(localStorage.getItem('curr_url') ===  window.location.pathname)
			{
				var saved_index = parseInt(localStorage.getItem('tr_index')) - 1;
				var pageNum = parseInt(localStorage.getItem('pg_num'));
				var index_to_select = (((pageNum - 1) * parseInt(localStorage.getItem('disp_len'))) + saved_index);
				$('tbody tr:eq('+ index_to_select +')').click();
			}
			else
			{
				var loadStateParams = false;
				$('tbody tr:eq('+ 0 +')').click();
				return loadStateParams;
			}

		},
		fnDrawCallback: function () {
	        table_id = '#' + this[0].id;
	        table_wrapper = $(table_id).parent();
	        if($(table_wrapper).find('.dataTables_paginate span .paginate_button').size() > 1)
			{
	          $(table_wrapper).find('.dataTables_paginate')[0].style.display = "block";
		  	}
	        else {
	          $(table_wrapper).find('.dataTables_paginate')[0].style.display = "none";
		  	}
	  	},
		dom: "<'top'l>rt<'bottom'ip><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		}

	});

	$('#sequence_analysis_no_onishi_found').removeClass('hidden').addClass("in");
	$('#sequence_analysis_table_dna').removeClass('hidden').addClass("in");
	$('#sequence_analysis_table_protein').removeClass('hidden').addClass("in");
	$('#sequence_analysis_table_onishi').removeClass('hidden').addClass("in");
	$('#sequence_analysis_additional_info').removeClass('hidden').addClass("in");
	$('#onishi_aa_profiles').removeClass('hidden').addClass("in");

	$('.loader').hide();


	var seq_analysis_table_dna = $('#sequence_analysis_table_dna').dataTable({"bAutoWidth": false, "scrollX": true,"bSort": false,
		dom: "<'top'>rt<'bottom'><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		}
	});

	var seq_analysis_table_protein = $('#sequence_analysis_table_protein').dataTable({"bAutoWidth": false, "scrollX": true,"bSort": false,
		dom: "<'top'>rt<'bottom'><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		}
	});

	var seq_analysis_onishi = $('#sequence_analysis_table_onishi').dataTable({"bAutoWidth": false, "bSort": false,
		dom: "<'top'>rt<'bottom'><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		}

	});




	//profile result datatable for allele query result page
	var profile_result_table = $('#profile_type_list').dataTable({"bSort": false, "iDisplayLength":25,
		dom: "<'top'>rt<'bottom'><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		}
	});

	//allele result datatable for allele query result page
	var allele_result_table = $('#allele_type_list').dataTable({"bSort": false,
		dom: "<'top'>rt<'bottom'><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		},
	});


	//multi allele result datatable for allele query result page
	var multi_allele_result_table = $('#multi_allele_type_list').dataTable({"aLengthMenu": [[5, 10, 25, -1], [5, 10, 25, "All"]], "iDisplayLength":10,"bSort": false,
		dom: "<'top'l>rt<'bottom'ip><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		},
	});

	//batch profile query result datatable for batch profile query result page
	var batch_st_query_result_table = $('#batch_st_query_table').dataTable({"bSort": false,
		dom: "<'top'l>rt<'bottom'ip><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		},
	});

	//active users datatable
	var active_users_table = $('#active-users-list').dataTable({"aLengthMenu": [[5, 10, 25, -1], [5, 10, 25, "All"]], "iDisplayLength":10,
		dom: "<'top'l>rt<'bottom'ip><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		},
	});

	//inactive users datatable
	var inactive_users_table = $('#inactive-users-list').dataTable({"aLengthMenu": [[5, 10, 25, -1], [5, 10, 25, "All"]], "iDisplayLength":10,
		dom: "<'top'l>rt<'bottom'ip><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		},
	});


	//inactive users datatable
	var onishi_aa_profiles_table = $('#onishi_aa_profiles').dataTable({"aLengthMenu": [[5, 10, 25, -1], [5, 10, 25, "All"]], "iDisplayLength":10,"bSort": false,
		dom: "<'top'l>rt<'bottom'ip><'clear'>",
		"language":
		{
			"url": $url_to_lang_file
		},
	});


	//Required to make popovers work past first page of results in datatables that have pagination

	table.$('[rel="popover-dt"]').popover({
        html : true,
	animation:false,

    }).on("mouseenter", function () {
		var _this = this;
        $('.popover').hide(); //Hide any open popovers on other elements.
        $(this).popover('show');
    }).on("mouseleave", function () {
        var _this = this;
        setTimeout(function () {
            if (!$(".popover:hover").length) {
                $(_this).popover("hide");
            }
        }, 0);
    }).focus(function () {
        $(this).trigger('mouseover');
    });

	 batch_st_query_result_table.$('[rel="popover-dt"]').popover({
		html : true,
	animation:false,

	}).on("mouseenter", function () {
		var _this = this;
		$('.popover').hide(); //Hide any open popovers on other elements.
		$(this).popover('show');
	}).on("mouseleave", function () {
		var _this = this;
		setTimeout(function () {
			if (!$(".popover:hover").length) {
				$(_this).popover("hide");
			}
		}, 0);
	}).focus(function () {
		$(this).trigger('mouseover');
	});


	$(window).bind("resize",function()
	{
		table.fnAdjustColumnSizing();
	});


	multi_allele_result_table.$('[rel="popover-dt"]').popover({
		html : true,
	animation:false,

	}).on("mouseenter", function () {
		var _this = this;
		$('.popover').hide(); //Hide any open popovers on other elements.
		$(this).popover('show');
	}).on("mouseleave", function () {
		var _this = this;
		setTimeout(function () {
			if (!$(".popover:hover").length) {
				$(_this).popover("hide");
			}
		}, 0);
	}).focus(function () {
		$(this).trigger('mouseover');
	});


	$(window).bind("resize",function()
	{
		multi_allele_result_table.fnAdjustColumnSizing();
	});

	$(window).bind("resize",function()
	{
		batch_st_query_result_table.fnAdjustColumnSizing();

	});

});


//selects radio button for row if user clicks anywhere
//in the row and changes bg color of current selected row

$('#type_list tr').click(function()
{

	$(this).find('input[type=radio]').prop('checked', true);

	var index = parseInt(this.rowIndex);
	localStorage.setItem('tr_index', index);

	$('#type_list tr td').not(this).each(function()
	{

		$(this).removeClass('active');
		$('#type_list tr td .dt-curator-comment-bg').css({"background-color":"#FFFFFF"});
	});

	$('#type_list tr:eq('+ index +') td').addClass('active');

	$('#type_list tr:eq('+ index +') td .dt-curator-comment-bg').css({"background-color":"#F9F9F9"});


});

$('#onishi_aa_profiles tr').click(function()
{

	$(this).find('input[type=radio]').prop('checked', true);

	var index = parseInt(this.rowIndex);
	localStorage.setItem('tr_index', index);

	$('#onishi_aa_profiles tr td').not(this).each(function()
	{

		$(this).removeClass('active');
		$('#onishi_aa_profiles tr td .dt-curator-comment-bg').css({"background-color":"#FFFFFF"});
	});

	$('#onishi_aa_profiles tr:eq('+ index +') td').addClass('active');

	$('#onishi_aa_profiles tr:eq('+ index +') td .dt-curator-comment-bg').css({"background-color":"#F9F9F9"});


});
