//USE: Showing position numbers and lining up sequences below these position numbers
//Convert sequences characters into individual spans and attach popovers with position numbers to each span


//ONISHI SEQUENCES
var str = $('#onishi-positions').text();
var modified_str = "";

var tokens = onishi_positions.split(",");

for (var i = 0, len = str.length; i < len; i++) {

  modified_str += "<span data-toggle='tooltip' data-placement='top' title='"+ tokens[i] +"'>"+str[i]+"</span>";

}

$('#onishi-positions').html(modified_str);

var str = $('#onishi-wt').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span>"+str[i]+"</span>";

}

$('#onishi-wt').html(modified_str);


var str = $('#onishi-us').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span>"+str[i]+"</span>";
}

$('#onishi-us').html(modified_str);

var str = $('#onishi-diff').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span>"+str[i]+"</span>";
}

$('#onishi-diff').html(modified_str);



//PROTEIN SEQUENCES

var str = $('#protein-positions').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span data-toggle='tooltip' data-placement='top' title='"+ (i+1) +"'>"+str[i]+"</span>";

}

$('#protein-positions').html(modified_str);

var str = $('#protein-wt').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span>"+str[i]+"</span>";
}

$('#protein-wt').html(modified_str);



var str = $('#protein-us').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span>"+str[i]+"</span>";
}

$('#protein-us').html(modified_str);


var str = $('#protein-diff').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span>"+str[i]+"</span>";
}

$('#protein-diff').html(modified_str);



//DNA SEQUENCES

var str = $('#dna-positions').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span data-toggle='tooltip' data-placement='top' title='"+ (i+1) +"'>"+str[i]+"</span>";

}

$('#dna-positions').html(modified_str);


var str = $('#dna-wt').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span>"+str[i]+"</span>";
}

$('#dna-wt').html(modified_str);



var str = $('#dna-us').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span>"+str[i]+"</span>";
}

$('#dna-us').html(modified_str);


var str = $('#dna-diff').text();
var modified_str = "";

for (var i = 0, len = str.length; i < len; i++) {

    modified_str += "<span>"+str[i]+"</span>";
}

$('#dna-diff').html(modified_str);
