# Day 1 - BioNix Workshop

Let's start by defining *computational reproducibility* as always
obtaining the same output from a computation given the same inputs. In
other words, computational reproducibility is about making computations
*deterministic*.  In the research context, this is important as
reproducibility allows others (and ourselves) to verify and build upon
what we have done in future.

# A functional view of things and why Nix is needed

What makes reproducibility difficult is the management of *state*, or
the context within with a computation takes place. State manipulation is
widespread:  how many apps updates or system updates do you recall
automatically being installed over the past year?  Do you think your
analysis today will be the same in one years time if your software stack
has changed?

One way to deal with this problem is to make computations *pure* by forbidding
the use of anything that is not explicitly stated as an input. This is
the same idea of pure functional programming, only at the higher level of
executing software.

Nix effectively enforces purity for software execution by ensuring the software
cannot access anything outside of the specified inputs. By this way, it can
guarantee a very high degree of reproducibility. Nix is a general build engine
most commonly used for building software today, but as we will see a bit later
it can also execute computational biology workflows in a pure manner with a small
library called BioNix.

# Pipelines in BioNix

```
# This is an example pipeline specification to do multi-sample variant calling
# with the Platypus variant caller. Each input is preprocessed by aligning
# against a reference genome (defaults to GRCH38), fixing mate information, and
# marking duplicates. Finally platypus is called over all samples.
{ bionix ? import <bionix> { }
, inputs
, ref ? bionix.ref.grch38.seq
}:

with bionix;
with lib;

let
  preprocess = flip pipe [
    (bwa.align { inherit ref; })
    (samtools.sort { nameSort = true; })
    (samtools.fixmate { })
    (samtools.sort { })
    (samtools.markdup { })
  ];

in
platypus.call { } (map preprocess inputs)
```

# Nix the language

We will start with learning Nix the langauge, which is used for
specifying workflows. If you are familar with JSON, it is very similar
in terms of availble data types but has one very important addition:
functions. Let's cover the basic data types and their syntax:

- Booleans: `true` and `false`
- Strings: `"this is a string"`
- Numbers: `0`, `1.234`
- Lists: `[ 0 1.234 "string" ]`
- Attribute sets: `{ a = 5; b = "something else"; }`
- Comments: `# this is a comment`
- Functions: `x: x + 1`
- Variable binding: `let x = 5; in x #=> 5`
- Function application: `let f = x: x + 1; in f 5 #=> 6`
- File paths: `/path/to/file`

Some common operators:
- Boolean conjunctions and disjunctions: `true || false #=> true` `true && false #=> false`
- Ordering: `3 < 3 #=> false`, `3 <= 3 #=> true`
- Conditionals: `if 3 < 4 then "a" else "b" #=> a`
- Addition and subtraction: `3 + 4 #=> 7`, `3 - 4 #=> -1`
- Multiplication and division: `3 * 4 #=> 12`, `3.0 / 4 #=> 0.75`
- String concatenation: `"hello " + "world" #=> "hello world"`
- String interpolation: `"hello ${"world"}" #=> "hello world"`, `"1 + 2 = ${toString (1 + 2)}" #=> "1 + 2 = 3"`
- Attribute set unions: `{ a = 5; } // { b = 6; } #=> { a = 5; b = 6; }`

# About this interface

This workshop uses [A tour of
nix](https://github.com/nixcloud/tour_of_nix) with some altered content
for the purposes of learning enough of Nix the language to write
workflows in BioNix during the second part. Click next to continue to
the exercises.
