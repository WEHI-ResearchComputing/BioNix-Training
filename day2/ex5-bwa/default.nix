/*
BioNix is a thin wrapper over Nix: there is not much functionality
required for pipelining that is not already present in the base build
engine. As such, the focus is on providing an interface that is
convenient for specifying common bioinformatics workflows. To this end,
BioNix provides a library of tools to help simplify the specification of
common bioinformatics pipelines, with a notable focus on genomics tools.
You can see the available tools at
https://github.com/PapenfussLab/bionix/tree/master/tools.

This exercise aims to demonstrate how to both use a tool available in
BioNix on some input data and how to chain them together. We will do a
simple alignment with BWA on some simulated reads from a bacterial
genome. The BWA tool is provided by
https://github.com/PapenfussLab/bionix/blob/master/tools/bwa.nix and as
you can see there are alignment functions for alignment with BWA/BWA2,
as well as corresponding index functions for indexing a reference
genome.  Don't worry about indexing, this will be handled automatically,
you only have to declare you want an alignment and what genome and the
index will be generated if needed.

Exercise:

1. Sample data along with a reference will be fetched from github. As
before, hashes of the content must be known. Fill in the hashes to fully
specify the inputs.

2. With the hashes in place, the expression should evaluate and BWA
should run.  Try swapping BWA out with some of the other available
aligners in BioNix (e.g., bowtie, hisat2, minimap2, whisper).

3. Aligners produce *unsorted* output, but co-ordinate sorted alignments
are usually desired as they are indexable by position. Pass the aligned
output to the samtools sort function to sort the alignments into co-
ordinate order.
*/
{bionix}:
with bionix; let
  input = {
    input1 = fetchFastQ {
      url = "https://raw.githubusercontent.com/PapenfussLab/bionix/bac9248a5e08e8afdf5485a6e27cfe72e1ca5090/examples/sample1-1.fq";
    };
    input2 = fetchFastQ {
      url = "https://raw.githubusercontent.com/PapenfussLab/bionix/bac9248a5e08e8afdf5485a6e27cfe72e1ca5090/examples/sample1-2.fq";
    };
  };

  ref = fetchFastA {
    url = "https://raw.githubusercontent.com/PapenfussLab/bionix/bac9248a5e08e8afdf5485a6e27cfe72e1ca5090/examples/ref.fa";
  };
in
  # if on an ARM (M1/2) mac BWA will be unavailable!
  bwa.align {} input
# use this instead on aarch64
#minimap2.align {preset = "sr";}

