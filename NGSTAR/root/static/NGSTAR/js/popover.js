//For popovers not in datatables
$(function(){

    $('[rel="popover"]').popover({
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
    }).blur(function () {
        $(this).trigger('mouseleave');
    });

});

//For popovers in datatables
$(function(){

    $('[rel="popover-dt"]').popover({
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

});


//Position marker popover using a tooltip
$(function(){

    $('[data-toggle="tooltip"]').tooltip();
});

//Allele Query Full Result popover
$(function(){

    $('[rel="popover-full-results"]').popover({
        html : true,
	animation:false,

    }).on("mouseenter", function () {
        var _this = this;
        $('.popover').hide(); //Hide any open popovers on other elements.

        $(this).popover('show');
        $('h3.popover-title').attr('style', 'background-color: #dff0d8 !important');
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

});

//Allele Query Partial Result popover
$(function(){

    $('[rel="popover-partial-results"]').popover({
        html : true,
	animation:false,

    }).on("mouseenter", function () {
        var _this = this;
        $('.popover').hide(); //Hide any open popovers on other elements.

        $(this).popover('show');
        $('h3.popover-title').attr('style', 'background-color: #f2dede !important');
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

});

//closes bootstrap popover by clicking outside the popover
$('body').on('click', function (e) {
    $('[rel="popover"]').each(function () {
        //the 'is' for buttons that trigger popups
        //the 'has' for icons within a button that triggers a popup
        if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
            $(this).popover('hide');
        }
    });
});


//closes bootstrap popover open in datatable by clicking outside the popover
$('body').on('click', function (e) {
    $('[rel="popover-dt"]').each(function () {
        //the 'is' for buttons that trigger popups
        //the 'has' for icons within a button that triggers a popup
        if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
            $(this).popover('hide');
        }
    });
});

$('.list-group-item').popover({html : 'true'});

$('#popover-classifications').popover({html : 'true'});
