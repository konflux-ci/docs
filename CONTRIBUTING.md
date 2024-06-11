# Konflux-CI documentation contributing guide

There are 2 different ways you can contribute to the {ProductName} documentation:

* **UI**: You can select **Edit this Page** in the banner on any page of the [Konflux documentation](https://konflux-ci.dev/docs) and suggest your changes in the web editor.

* **GitHub**: You can fork the [Konflux-CI/docs repository](https://github.com/konflux-ci/docs) on GitHub and edit documentation locally on your machine. 

## Contributing with your own fork

When contributing to documentation, we recommend that you:

- Create a [fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo) of the [Konflux-CI/docs repository](https://github.com/konflux-ci/docs).

- Suggest your updates in the forked repository on a task-specific branch.

- When changes are ready for a review, open a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests) against the default *main* branch of the upstream Konflux docs repository.

When you submit a PR, the Konflux team reviews it and arranges further reviews as required.

## Working with AsciiDoc

The Konflux documentation is developed in AsciiDoc format. AsciiDoc is a plain text documentation syntax, also known as a mark-up language, for text files. Asciidoctor, the core processor for the AsciiDoc language, converts AsciiDoc files to HTML, so readers can view files as formatted text via the GitHub repository URL.

### Rendering individual pages

To render individual AsciiDoc pages for review, use the `asciidoctor` software to generate HTML files.

To install `asciidoctor` on Fedora or RHEL:

```bash
sudo dnf install -y asciidoctor
```

To create HTML files on your local system:

```bash
asciidoctor <name>.adoc
```

There are also Integrated Development Environments (IDEs) that will render
AsciiDoc pages while editing. Check the documentation of your specific IDE
for information on enabling AsciiDoc rendering.

**IMPORTANT:**
> Final rendering of the documentation is done with Antora,
> which overrides some of the AsciiDoctor formatting. Use the instructions
> below to render the entire site for a final check of any changes to the
> documentation.

### Rendering the entire site

To locally render the entire site, navigate to the root of the repository
and run:

```bash
npm install
npm run build
```

Then visit http://127.0.0.1:8080.


The site rendered by Antora with the commands above is not dynamic, the pages
will not be re-rendered automatically if the AsciiDoc files change. You can
set up watchmedo from watchdog to rerun the server after every AsciiDoc
file change using the command below. Be aware, the server will take a few
seconds to restart every time a file changes.

```bash
python3 -m venv venv
source venv/bin/activate
python -m pip install watchdog[watchmedo]
watchmedo auto-restart --patterns="*.adoc" --recursive npm run dev
```

### Converting Markdown to AsciiDoc

If you prefer to work with Markdown, you can convert your Markdown files into AsciiDoc using any conversion tool, for example Pandoc:

1. Install [Pandoc](https://pandoc.org/installing.html)

2. Convert a file by running the following command:

```bash
pandoc [file name].md -f markdown -t asciidoc [file name].adoc
```

The `-f` option specifies the input format, and the `-t` option specifies the output format. For more options, see [General options](https://pandoc.org/chunkedhtml-demo/3.1-general-options.html) for the `pandoc` command.

3. Render the resulting AsciiDoc file using the Integrated Development Environment (IDE) of your choice, the `asciidoctor` text processor, or any other option.

### AsciiDoc mark-up language references

The [AsciiDoc Writer's Guide](https://asciidoctor.org/docs/asciidoc-writers-guide/)
"provides a gentle introduction to AsciiDoc".
It introduces the syntax in an easy to understand narrative with examples.

The [AsciiDoc Syntax Quick Reference](https://asciidoctor.org/docs/asciidoc-syntax-quick-reference/)
contains concise information on all the syntax available in AsciiDoc.

The [Red Hat Conventions for AsciiDoc Mark-up](https://redhat-documentation.github.io/asciidoc-markup-conventions/)
contains the Red Hat specific conventions for documentation written in
AsciiDoc.