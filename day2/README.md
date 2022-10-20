# Day 2 – BioNix workshop

During Day 1 we focused on learning the basics of the Nix configuration
language, this session will focus on putting that into practice by building and
executing small reproducible examples. You therefore will need Nix installed, a
terminal for interacting with it, and this git repository.

## Cloning the repository

You will need a copy of this repository to interact with the exercises. Clone
it with:

     git clone --depth 1 https://github.com/WEHI-ResearchComputing/BioNix-Training.git

and take a look at the `day2` directory.

## Installing and configuring Nix

Nix can be installed by following the instructions at
https://nixos.org/download.html. For WEHI Mac uses, Nix is available in the
Software Centre for install.

Nix is also available on Milton after a `module load nix`, however it is
recommended to use a local install if available for the workshop as the Milton
module is configured to submit jobs to the Slurm queue, so waiting times may be
variable depending on the load. It is worth trying some of the exercises on
Milton after completion though, to see how easily things can be shifted to
execution on the cluster without extensive changes.

This workshop also uses a couple of extensions that need to be enabled. Ensure
you have the following line in `~/.config/nix/nix.conf`:

    experimental-features = nix-command flakes

## The Nix command

The `nix` command is used for interacting with the Nix build system and
requesting builds or querying the dependency graphs. To see help run

    nix --help

which will display a manpage detailing the subcommands that are available. For
the most part, you will be using `nix build` to request the output for
something, and you can see the man page for the subcommand with

    nix build --help

Another important command is `nix store gc`, which requests the nix store to
clean up all unnecessary files. Nix provides it's isolation by ensuring all
inputs and outputs are in the *Nix store* located at `/nix/store`. The store can
grow to large sizes, especially if some of the outputs are large like with
sequencing. Unnecessary paths are kept as a cache, it speeds up rerunning of
builds that may depend on things that have already been computed. Running
garbage collection removes paths in the store that are not referenced either by
a currently used output or by a currently running build, and there are some
configuration options for automatically triggering GC when needed (see
`min-free` and `max-free` of the `nix.conf` manpage).

The `search` command is useful as it allows searching a flake's output for
keywords. One particularly useful example is when using Nix as a package
manager, then the `nixpkgs` repository can easily be searched for software. As
an example, `nix search nixpkgs genome` will output all available software with
`genome` in the description. The software can then be accessed by dropping into
a shell, e.g.,:

    nix shell nixpkgs#{SPAdes,quast}

which will provide a shell containing both SPAdes and quast.

## Working through the exercises

To work through the exercises, change into the directory and read the comment at
the top of `default.nix`. Except for the first exercise on declarative shells,
the exercises can be built with

    nix build

in the directory. The solution is provided in `solution.nix` and can be built
with

    nix build .#solution

however you should try to solve the problem yourself before looking at the
solution. A successful build will create a symlink called `./result` by default
to the result of the build.

## Flakes and hermetic sealing

These exercises use an extension to Nix called *flakes*, which allow for
hermetically sealing all the input requirements such as *nixpkgs* and *bionix*.
How this works is beyond the scope of this workshop, however you can take a look
at one of the `flake.nix` to see how inputs are defined followed by outputs (our
workshop exercises) based on the inputs. The `flake.lock` is automatically
created by Nix and pins the versions of all the inputs precisely.

## BioNix and how it is structured

Bionix is organised into a tree of functions with two levels, the first being
the tool and the second being the action to take with that tool. An example is
using the BWA aligner to align some sequences against a reference genome: the
function is named `bionix.bwa.align`. This convention allows different tools to
be swapped with minimal changes, for example using bowtie2 instead of BWA for
alignment would mean just using the function `bionix.bowtie2.align` instead.

These functions are structed to take two parameters, the first is configuration
for the tool and the second is the input. Continuing our example of BWA, the
first argument specifies the reference (configuration) and the second the
sequences to align: `bionix.bwa.align { ref = ...; } { input1 = ...; input2 =
...; }`. Separating out the config like this allows us to write pipelines by
function composition, e.g., to align and then sort the output one could do:

    bionix.samtools.sort { /* config for sort */ } (bionix.bwa.align { ref = ...; } { input1 = ...; input2 = ...; })

or, taking advantage of the handy library function `pipe`:

    bionix.lib.pipe {input1 = ...; input2 = ...; } [
      (bionix.bwa.align { ref = ...;})
      (samtools.sort {})
    ]

NB: list elements are separated by space, but function application is also
separated by space! Make sure to parenthesise your function compositions, as
above, in lists.

The best way to see what's available is to just [browse the
repository](https://github.com/PapenfussLab/bionix/tree/master/tools). You can
always write your own *stages*, or concrete processing steps. This is just a
function in the top-level bionix tree, e.g.,:

    bionix.stage {
      name = "my-stage";
      buildInputs = [];
      buildCommand = ''
      '';
    }

Stages have to have a name and a `buildCommand`, which is a shell script
(executed with bash) that does the computation and writes output to the path
given by the environment variable `$out`. `buildInputs` is a list of required
software for the `buildCommand`. The exercises in this part of the workshop
focus on showing how different type of stages can be constructed.

## Where to get help

There are several avenues of support available for Nix, nixpkgs, and BioNix. The
official channels are listed [on the main website](https://nixos.org/learn.html).
There you will find many guides about how to setup ad-hoc environments, or more
reproducible environments, as well as documentation for Nix, nixpkgs, and NixOS,
an operating system built on Nix.

There are several Matrix chat rooms for support. For general Nix or nixpkgs
questions use the [#nix:nixos.org](https://matrix.to/#/#nix:nixos.org) room. For
BioNix specific questions there's [#bionix:nixos.org](https://matrix.to/#/#bionix:nixos.org).
The [Nix community Matrix space](https://matrix.to/#/#community:nixos.org) is
good to join to see what topic specific rooms are available.

Finally there's a [discourse forum](https://discourse.nixos.org/) available for
Nix/nixpkgs questions.
