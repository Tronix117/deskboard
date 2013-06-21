Deskboard
=========

Launchpad like as replacement for the desktop


---

Will soon be delivered with a setting panel, but for the moment and for better compatibility with Space, it's strongly advised to remove the Desktop layer of your user.

To do so, enter the following in your terminal:

    defaults write com.apple.finder CreateDesktop -bool FALSE;killall Finder
    
To reactivate it:
    
    defaults write com.apple.finder CreateDesktop -bool FALSE;killall Finder
