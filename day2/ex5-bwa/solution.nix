{bionix}:
with bionix; let
  input = {
    input1 = fetchFastQ {
      url = "https://raw.githubusercontent.com/PapenfussLab/bionix/master/examples/sample1-1.fq";
      sha256 = "sha256-qE6s8hKowiz3mvCq8/7xAzUz77xG9rAcsI2E50xMAk4=";
    };
    input2 = fetchFastQ {
      url = "https://raw.githubusercontent.com/PapenfussLab/bionix/master/examples/sample1-2.fq";
      sha256 = "sha256-s02R49HX/qeJp4t/eZwsKwV9D07uLGId8CEpU2dB8zM=";
    };
  };

  ref = fetchFastA {
    url = "https://raw.githubusercontent.com/PapenfussLab/bionix/master/examples/ref.fa";
    sha256 = "sha256-V3zqOJFuGtukDRQttK/pGfKofgOlKrridHaWYhGGyWs=";
  };
in
  samtools.sort {} (minimap2.align {preset = "sr"; inherit ref;} input)
