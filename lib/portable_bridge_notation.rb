##
# Please see ../../Readme.md
module PortableBridgeNotation
  ##
  # Please see ../../Readme.md
  module Api
    autoload :Importer, File.expand_path('../portable_bridge_notation/api/importer', __FILE__)
    autoload :Game, File.expand_path('../portable_bridge_notation/api/game', __FILE__)
  end
end
