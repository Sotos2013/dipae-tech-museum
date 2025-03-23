# Install pods needed to embed Flutter application, Flutter engine, and plugins
def flutter_installation
  install_flutter_engine_pod
  install_flutter_plugin_pods
end

def install_flutter_engine_pod
  engine_dir = File.expand_path(File.join('..', '..', 'bin', 'cache', 'artifacts', 'engine', 'ios'), __dir__)
  pod 'Flutter', :path => engine_dir
end

def install_flutter_plugin_pods
  plugins_file = File.expand_path(File.join('..', '.flutter-plugins-dependencies'), __dir__)
  return unless File.exist?(plugins_file)

  plugin_pods = JSON.parse(File.read(plugins_file))["plugins"]["ios"]
  plugin_pods.each do |plugin|
    pod plugin["name"], :path => File.expand_path(plugin["path"], __dir__)
  end
end
