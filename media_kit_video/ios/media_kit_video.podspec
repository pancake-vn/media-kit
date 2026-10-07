#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint media_kit_video.podspec` to validate before publishing.
#

require_relative '../common/darwin/Podspec/media_kit_utils.rb'

Pod::Spec.new do |s|
  # Setup required files
  # iOS still links libmpv v0.36-era xcframeworks (libmpv-darwin-build v0.6.0), so keep the
  # matching headers. Bump together with media_kit_libs_ios_video.
  system("make -C ../common/darwin HEADERS_DESTDIR=\"$(pwd)/Headers\" MPV_HEADERS_VERSION=v0.36.0 MPV_HEADERS_SHA256SUM=29abc44f8ebee013bb2f9fe14d80b30db19b534c679056e4851ceadf5a5e8bf6 MPV_HEADERS_STRIP_COMPONENTS=2 'MPV_HEADERS_GLOB=mpv-*/libmpv/*.h'")

  # Initialize `MediaKitUtils`
  mku = MediaKitUtils.new(MediaKitUtils::Platform::IOS)

  s.name             = 'media_kit_video'
  s.version          = '0.0.1'
  s.summary          = 'Native implementation for video playback in package:media_kit'
  s.description      = <<-DESC
  Native implementation for video playback in package:media_kit.
                       DESC
  s.homepage         = 'https://github.com/media-kit/media-kit.git'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Hitesh Kumar Saini' => 'saini123hitesh@gmail.com' }

  s.source           = { :path => '.' }
  s.platform         = :ios, '9.0'
  s.swift_version    = '5.0'
  s.dependency         'Flutter'
  
  if mku.libs_found
    # Define paths to frameworks dir
    framework_search_paths_iphoneos        = sprintf('$(PROJECT_DIR)/../.symlinks/plugins/%s/ios/Frameworks/.symlinks/mpv/ios', mku.libs_package)
    framework_search_paths_iphonesimulator = sprintf('$(PROJECT_DIR)/../.symlinks/plugins/%s/ios/Frameworks/.symlinks/mpv/ios-simulator', mku.libs_package)

    s.source_files        = 'Classes/plugin/**/*.swift', 'Headers/**/*.h'
    s.pod_target_xcconfig = {
      'DEFINES_MODULE'                               => 'YES',
      'GCC_WARN_INHIBIT_ALL_WARNINGS'                => 'YES',
      'GCC_PREPROCESSOR_DEFINITIONS'                 => '"$(inherited)" GL_SILENCE_DEPRECATION COREVIDEO_SILENCE_GL_DEPRECATION',
      'FRAMEWORK_SEARCH_PATHS[sdk=iphoneos*]'        => sprintf('"$(inherited)" "%s"', framework_search_paths_iphoneos),
      'FRAMEWORK_SEARCH_PATHS[sdk=iphonesimulator*]' => sprintf('"$(inherited)" "%s"', framework_search_paths_iphonesimulator),
      'OTHER_LDFLAGS'                                => '"$(inherited)" -framework Mpv',
      # Flutter.framework does not contain a i386 slice.
      'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    }
  else
    s.source_files        = 'Classes/stub/**/*.swift'
    s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  end
end
