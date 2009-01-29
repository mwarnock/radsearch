# Include hook code here
#ActionController::Base.send(:include, SomSkin::ControllerMethods) #Produces bizarre no method responded to action behavior
ActionView::Base.send :include, SomSkin::Helpers
