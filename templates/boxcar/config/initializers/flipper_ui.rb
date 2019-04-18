Flipper::UI.configure do |config|
    PRODUCTION_WARNING = "Proceed with Caution: You are making modifications to features in the Production Environment."
    DEVELOPMENT_WARNING = "You are making modifications to features in the Development environment."
    
    banner_class = Rails.env.production? ? 'danger' : 'warning'
    banner_text = Rails.env.production? ? PRODUCTION_WARNING : DEVELOPMENT_WARNING
    
    config.banner_text = banner_text
    config.banner_class = banner_class
end
