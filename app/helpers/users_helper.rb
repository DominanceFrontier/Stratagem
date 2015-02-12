module UsersHelper

  # Returns the user's avatar.
  def avatar_for(user)
    image_tag("user", alt: user.username, class: "avatar")    
  end
  
end
