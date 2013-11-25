(** Since there are only notations in [NaturalTransformation.Notations], we can just export those. *)
Require Export NaturalTransformation.Notations.

Require NaturalTransformation.Composition.Core.
Require NaturalTransformation.Core.
Require NaturalTransformation.Dual.
Require NaturalTransformation.Identity.
Require NaturalTransformation.Paths.
Require NaturalTransformation.Sum.

Include NaturalTransformation.Composition.Core.
Include NaturalTransformation.Core.
Include NaturalTransformation.Dual.
Include NaturalTransformation.Identity.
Include NaturalTransformation.Paths.
Include NaturalTransformation.Sum.
(** We don't want to make utf-8 notations the default, so we don't export them. *)

(** Since [Composition] is a separate sub-directory, we need to re-create the module structure *)
Module Composition.
  Require NaturalTransformation.Composition.Composition.
  Include NaturalTransformation.Composition.Composition.
End Composition.