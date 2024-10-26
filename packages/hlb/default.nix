{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule {
  pname = "hlb";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "openllb";
    repo = "hlb";
    rev = "8955839ad1617fe27f7687cbd82b29e0b0d83a93";
    hash = "sha256-SyA2+Oc7mELgZwaGTWO793p5AxukLGJaKdQZdPKIuhw=";
  };

  vendorHash = "sha256-Ss/LfVoXrp9ujW7789iyc9mCq+sTQ2pwGiz2E7TdWl0=";

  meta = with lib; {
    description = "High-level build language for BuildKit";
    homepage = "https://github.com/openllb/hlb";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
