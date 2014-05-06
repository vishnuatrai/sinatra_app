function loadOccasion(occasion_id) {
    $.get('/occasions/' + occasion_id, function (data) {
        $("#gift_queue").html(data);
        addAGiftClick();
        editAGiftClick();
        setGiftClick();
        setRecommendationClick();
    });
}


function setOccasionClick() {
    $(".occasion_row").click(function (event) {
        var occasion_id = $(this).attr('id');
        loadOccasion(occasion_id);
    });
}

function loadGift(gift_id, type) {
    if (!type) {
        type = "gift"
    }
    $.get('/' + type + 's/' + gift_id, function (data) {
        $("#gift_detail").html(data);
    });
}

function deleteGiftClick() {
    $(".delete_gift").click(function () {
        var gift_id = $(this).attr("data-id");
        $.get('/gifts/' + gift_id+'/delete', function (data) {
            loadOccasion($("#occasion_id").val());
            $("#gift_detail").html("");
        });
    });
}

function setRecommendationClick() {
    $(".recommendation_row").click(function (event) {
        recommendation_id = $(this).attr('data-id');
        loadGift(recommendation_id, "recommendation");
    });
}

function deleteRecommendationClick() {
    $(".delete_recommend_gift").on("click", function (event) {
        recommendation_id = $(this).attr('data-id');
        $("tr").remove("#"+recommendation_id);
        $("#gift_detail").html("");
        alert("ads");
//        loadGift(recommendation_id, "recommendation");
    });
}

function setGiftClick() {
    $(".queued_row").click(function (event) {
        queued_id = $(this).attr('data-id');
        loadGift(queued_id);
    });
}

function submitNewGiftClick(occasion_id) {
    $('.new-gift').submit(function () {
        var data = $(this).serialize();
        $.post('/occasions/' + occasion_id + '/gifts', data,
            function (data) {
                if (data['success']) {
                    loadOccasion(occasion_id);
                    loadGift(data['id']);
                }
            }, 'json')
        return false;
    })
}

function recommendNewGiftClick() {
    $('.recommend-add-gift').on("click",function () {
        var occasion_id = $(this).attr('data-occasion-id');
        var recommend_id = $(this).attr('data-recommend-id');
        $.post('/occasions/' + occasion_id + '/recommend/' + recommend_id + '/create',
            function (data) {
                if (data['success']) {
                    loadOccasion(occasion_id);
                    loadGift(data['id']);
                }
            }, 'json')
        return false;
    })
}

function submitEditGiftClick(gift_id) {
    $('.edit-gift').submit(function () {
        var data = $(this).serialize();
        $.post('/gifts/'+ gift_id +'/update', data,
            function (data) {
                if (data['success']) {
                    loadGift(data['id']);
                }
            }, 'json')
        return false;
    })
}

function addAGiftClick() {
    $(".add_a_gift").click(function (event) {
        var occasion_id = $(this).attr('data-occasion-id');
        $.get('/occasions/' + occasion_id + '/gifts/new', function (data) {
            $('#gift_detail').html(data);
            submitNewGiftClick(occasion_id);
        });
    });
}

function editAGiftClick() {
    $(".edit_a_gift").click(function (event) {
        var gift_id = $(this).attr('data-gift-id');
        $.get('/gifts/' + gift_id + '/edit', function (data) {
            $('#gift_detail').html(data);
            submitEditGiftClick(gift_id);
        });
    });
}

var setOccasionAvailable = true;

setOccasionClick();
setRecommendationClick();
recommendNewGiftClick();
deleteRecommendationClick();
addAGiftClick();
editAGiftClick();
setGiftClick();




$(".friends_list").click(function (event) {
    var user_id = $(this).attr("id");
    $.get('/users/' + user_id, function (data) {
        $("#gift_queue").html(data);
        addAGiftClick();
        setGiftClick();
        setRecommendationClick();

    });

});




  // var cells, desired_width;
  // cells = $('.table').find('tr')[0].cells.length;
  // desired_width = 940 / cells + 'px';
  // $('.table td').css('width', desired_width);
   



