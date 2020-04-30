### [ReScience C](https://rescience.github.io/) article template

This repository is a very raw stub for a check on reproducing results from
at least one section of a paper published in 2008. The attempt to reproduce
the results will constitute a research article to be submitted as a ReScience
C article with a (mandatory) YAML metadata file.

#### Usage

For a submission, fill in information in
[metadata.yaml](./metadata.yaml), modify [content.tex](content.tex)
and type:

```bash
$ make
```

This will produce an `article.pdf` using xelatex and provided font. Note that you must have Python 3 and [PyYAML](https://pyyaml.org/) installed on your computer, in addition to `make`.


After acceptance, you'll need to complete [metadata.yaml](./metadata.yaml) with information provided by the editor and type again:

```bash
$ make
```
