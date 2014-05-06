$(".add_friend").click(function(event){
  if ($(this).attr('disabled')) {
    return;
  }
  button = $(this);
  $.post('/add_friend',
    {
      facebook_id: $(this).attr('id'),
      first_name: $(this).attr('firstname'),
      last_name: $(this).attr('lastname'),
      birthday: $(this).attr('birthday')
    },
    function(data) {
      button.attr('disabled', 'disabled');
      button.text('Added');
    }
  );
});