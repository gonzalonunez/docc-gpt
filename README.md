# DoccGPT 🧹

![](https://github.com/gonzalonunez/docc-gpt/actions/workflows/build.yml/badge.svg)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgonzalonunez%2Fdocc-gpt%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/gonzalonunez/docc-gpt)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgonzalonunez%2Fdocc-gpt%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/gonzalonunez/docc-gpt)

https://user-images.githubusercontent.com/6403910/227589893-a1c47996-df5a-4d37-83a8-65bd5c515912.mov

---

DoccGPT is an experiment in fully automating the documentation of a Swift codebase. It is not quite there yet, but we'll get there (read the FAQ below).

It works by leveraging [OpenAI](https://platform.openai.com/docs/api-reference/completions) and [DocC](https://developer.apple.com/documentation/docc), Apple's documentation compiler:

> The DocC documentation compiler converts Markdown-based text into rich documentation for Swift and Objective-C projects, and displays it right in the Xcode documentation window. You can also host this documentation on a website.

By pairing DoccGPT together with the [Swift Package Index](https://blog.swiftpackageindex.com/posts/auto-generating-auto-hosting-and-auto-updating-docc-documentation/) (which compiles and hosts your documentation for you) you can come very close to a fully self-documenting codebase. DoccGPT writes the markup for you, or at least takes an initial pass at it, and the Swift Package Index takes care of compiling and hosting the generated documentation for you.

Almost all of the markup in `/Sources` was generated by running DoccGPT on itself:

```diff
+ /// A class for running the OpenAI GPT API to document Swift files.
struct DoccGPTRunner {

  // MARK: Internal

+ /// The API key used to authenticate with the OpenAI API.
  let apiKey: String

+  /**
+   Runs the OpenAI GPT API to document Swift files in a directory.
+
+   - Parameter directoryURL: The URL of the directory containing the Swift files to document.
+
+   - Throws: `DoccGPTRunnerError` if an error occurs.
+   */
  func run(in directoryURL: URL) async throws {
    try await documentFiles(in: directoryURL)
  }

  // MARK: Private

+ /// The base URL for the OpenAI API.
  private let baseURL = URL(string: "https://api.openai.com/v1/completions")!

+ /// The `FileManager` used to access the filesystem.
  private let fileManager = FileManager.default

+ /// A set of files to ignore when running the OpenAI API.
  private let ignoredFiles: Set<String> = [
    "Package.swift",
  ]
```

Depending on the OpenAI model that it uses, DoccGPT is smart enough to document long and complex Swift code. Simpler models seem to struggle more as the amount of code increases.

## Basic usage

Run the executable and give it a directory as well as your [OpenAI secret key](https://platform.openai.com/account/api-keys).

> **Warning**
> DoccGPT will attempt to rewrite the contents of every single `.swift` file in the directory that you give it. And if you feed it a sufficiently long file it won't make it all the way to the end!

```bash
swift run docc-gpt <directory> [--model <model>] --key <key> [--log-level <log-level>] [--skip-files <skip-files>]
```

```bash
ARGUMENTS:
  <directory>             The folder whose contents you want to document

OPTIONS:
  -m, --model <model>     The id of the OpenAI model to run (default: Model(id: "gpt-3.5-turbo", contextLength: 4096))
  -k, --key <key>         Your secret API key for OpenAI
  -l, --log-level <log-level>
                          The desired log level (default: info)
  --skip-files <skip-files>
                          Whether or not files that are too long to documented should be skipped (default: true)
  -h, --help              Show help information.
```

## How it works

DoccGPT is a command-line tool written in Swift that iterates through all `.swift` files in a given directory and attempts to document your code using [DocC](https://developer.apple.com/documentation/docc) syntax:

> DocC syntax — called documentation markup — is a custom variant of Markdown that adds functionality for developer documentation-specific features, like cross-symbol linking, term-definition lists, code listings, and asides.

At the time of writing, the documentation markup is generated by feeding entire `.swift` files to `/v1/chat/completions`. I have not noticed any comparable difference in performance between `gpt-3.5-turbo` and `gpt-4`. Feeding in entire files may sound like the naïve thing to do, but it seems to result in some pretty impressive behavior–I was surprised by how specific some of the comments in `/Sources` are and the way in which the models seem to "read" the entire file before adding comments.

## FAQ

#### What's missing?

The biggest issue is the context window of the currently available models. I was unable to fully document `DoccGPTRunner.swift` because I ran out of tokens, even with GPT-4. The current token limits at the time of writing are not viable for what I would say is the average Swift file. However, the soon-to-be available context windows of 32k tokens for GPT-4 should widely increase the scope of DoccGPT and get us significantly closer to a production-ready tool.

I also haven't figured out what to do about re-running the model on a file that has already been documented. With more complex code, models will make different decisions than the ones they had made previously. A second pass over code that has already been commented on seems to pretty consistently result in terrible changes. Perhaps most importantly, I have also not figured out how to get it to re-document code if the functionality has changed. That said, all of this can probably be fixed with better prompting or a better model.

Lastly, there is quite a bit of other basic CLI work needed to take this all of the way to a usable state, like exposing the ability to ignore certain files/subdirectories.

#### Would I use this in production?

I am not aware of the privacy implications of sending an entire codebase up to OpenAI's servers, but for that reason alone I would probably not use this.

Assuming we address the privacy implications and the limitations described above, maybe? I would probably avoid auto-committing anything through CI, although these models seem to be very good at documenting code in a deterministic and high quality way when doing it for the very first time.

That said, I do not think it is far-fetched at all to expect fully automated self-documenting codebases in the near-term future. My current first impressions are that a good prompt goes a long way and that there are huge performance differences between different models / APIs. I'm excited for a future where we can run powerful models with large context windows locally.

## One more thing...

The curious reader may notice that some of the documentation examples used in the prompt come from the inimitable [NSHipster](https://nshipster.com/swift-documentation/). I'm a longtime fan and tremendous appreciator of everything that NSHipster has done for mobile developers everywhere.
