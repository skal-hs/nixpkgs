{
  appimageTools,
  fetchurl,
  lib,
  makeWrapper,
}:

let
  pname = "wootility";
  version = "4.7.3";
  src = fetchurl {
    url = "https://s3.eu-west-2.amazonaws.com/wooting-update/wootility-lekker-linux-latest/wootility-lekker-${version}.AppImage";
    sha256 = "sha256-5S4Yz2VymKfT1uBXYufb6MWx1aMbGn4ufT8RITJtuPc=";
  };
in

appimageTools.wrapType2 {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ];

  extraInstallCommands =
    let
      contents = appimageTools.extract { inherit pname version src; };
    in
    ''
      wrapProgram $out/bin/wootility \
        --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations --enable-wayland-ime=true}}"

      install -Dm444 ${contents}/wootility-lekker.desktop -t $out/share/applications
      install -Dm444 ${contents}/wootility-lekker.png -t $out/share/pixmaps
      substituteInPlace $out/share/applications/wootility-lekker.desktop \
        --replace-fail 'Exec=AppRun' 'Exec=wootility' \
        --replace-warn 'Name=wootility-lekker' 'Name=Wootility'
    '';

  profile = ''
    export LC_ALL=C.UTF-8
  '';

  extraPkgs =
    pkgs: with pkgs; ([
      xorg.libxkbfile
    ]);

  meta = {
    homepage = "https://wooting.io/wootility";
    description = "Customization and management software for Wooting keyboards";
    platforms = lib.platforms.linux;
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [
      davidtwco
      sodiboo
      returntoreality
    ];
    mainProgram = "wootility";
  };
}
