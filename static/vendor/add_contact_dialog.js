$(function() {
    var first_name = $( "#first_name" ),
        last_name = $( "#last_name" ),
        relationship = $( "#relationship" ),
        day = $( "#day" ),
        month = $("#month"),
        allFields = $( [] ).add( first_name).add( last_name ).add( day ).add( month ),
        tips = $( ".validateTips" );
    function updateTips( t ) {
        tips
            .text( t )
            .addClass( "ui-state-highlight" );
        setTimeout(function() {
            tips.removeClass( "ui-state-highlight", 1500 );
        }, 500 );
    }

    function checkRequired(o, n){
        if(o.val() == ""){
            o.addClass( "ui-state-error" );
            updateTips( n + " is required.");
            return false;
        } else {
            return true;
        }
    }


    function checkLength( o, n, min, max ) {
        if ( o.val().length > max || o.val().length < min ) {
            o.addClass( "ui-state-error" );
            updateTips( "Length of " + n + " must be between " +
                min + " and " + max + "." );
            return false;
        } else {
            return true;
        }
    }

    function checkRegexp( o, regexp, n ) {
        if ( !( regexp.test( o.val() ) ) ) {
            o.addClass( "ui-state-error" );
            updateTips( n );
            return false;
        } else {
            return true;
        }
    }
    $( "#dialog-form" ).dialog({
        autoOpen: false,
        height: 360,
        width: 350,
        modal: true,
        buttons: {
            "Save Contact": function() {
                var bValid = true;
                allFields.removeClass( "ui-state-error" );
                bValid = bValid && checkRequired(first_name, "First Name");
                bValid = bValid && checkRequired(relationship, "Relationship");
                bValid = bValid && checkRequired(day, "Birth Date");
                bValid = bValid && checkRequired(month, "Birth Month");
                bValid = bValid && checkLength( first_name, "First Name", 3, 16 );
                bValid = bValid && checkRegexp( first_name, /^[a-z]([0-9a-z_])+$/i, "First Name may consist of a-z, 0-9, underscores, begin with a letter." );

// From jquery.validate.js (by joern), contributed by Scott Gonzalez: http://projects.scottsplayground.com/email_address_validation/

                if ( bValid ) {
                    $("#add_contact").submit();
                    $( this ).dialog( "close" );
                }
            },
            Cancel: function() {
                $( this ).dialog( "close" );
            }
        },
        close: function() {
            allFields.val( "" ).removeClass( "ui-state-error" );
        }
    });
    $( "#create-user" )
        .button()
        .click(function() {
            $( "#dialog-form" ).dialog( "open" );
        });




//for editing the contact

    $(".edit_contact").click(function (event) {
        var user_id = $(this).attr("id");

        $.get('/edit_user/' + user_id, function (data) {
            $("#dialog-form_user_details").html(data);
            $("#dialog-form_user_details").dialog( "open" );
        })
    });



    $( "#dialog-form_user_details" ).dialog({
    autoOpen: false,
    height: 360,
    width: 350,
    modal: true,
    buttons: {
        "Delete Contact": function() {
            window.location.pathname ="/delete_contact/"+$("#update_contact").attr("class")
        },
        "Save Contact": function() {
            var bValid = true;
            if ( bValid ) {
                $("#update_contact").submit();
                $( this ).dialog( "close" );
            }
        }

    },
    close: function() {
        allFields.val( "" ).removeClass( "ui-state-error" );
    }
});
});
