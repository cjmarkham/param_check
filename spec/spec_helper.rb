$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "param_check"

I18n.backend.store_translations(
  :en,
  YAML.load_file(File.open('./config/locales/en.yml'))['en']
)
