{ stdenv, lib, fetchurl, gnum4 }:

stdenv.mkDerivation rec {
  pname = "adns";
  version = "1.6.0";

  src = fetchurl {
    urls = [
      "https://www.chiark.greenend.org.uk/~ian/adns/ftp/adns-${version}.tar.gz"
      "ftp://ftp.chiark.greenend.org.uk/users/ian/adns/adns-${version}.tar.gz"
      "mirror://gnu/adns/adns-${version}.tar.gz"
    ];
    sha256 = "1pi0xl07pav4zm2jrbrfpv43s1r1q1y12awgak8k7q41m5jp4hpv";
  };

  nativeBuildInputs = [ gnum4 ];

  preConfigure =
    lib.optionalString stdenv.isDarwin "sed -i -e 's|-Wl,-soname=$(SHLIBSONAME)||' configure";

  # https://www.mail-archive.com/nix-dev@cs.uu.nl/msg01347.html for details.
  doCheck = false;

  postInstall = let suffix = lib.versions.majorMinor version;
  in lib.optionalString stdenv.isDarwin ''
    install_name_tool -id $out/lib/libadns.so.${suffix} $out/lib/libadns.so.${suffix}
  '';

  # darwin executables fail, but I don't want to fail the 100-500 packages depending on this lib
  doInstallCheck = !stdenv.isDarwin;
  installCheckPhase = ''
    set -eo pipefail

    for prog in $out/bin/*; do
      $prog --help > /dev/null && echo $(basename $prog) shows usage
    done
  '';

  meta = with lib; {
    homepage = "http://www.chiark.greenend.org.uk/~ian/adns/";
    description = "Asynchronous DNS Resolver Library";
    license = licenses.lgpl2;

    platforms = platforms.unix;
  };
}
