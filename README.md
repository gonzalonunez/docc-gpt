# DoccGPT 🧹

![](https://github.com/gonzalonunez/docc-gpt/actions/workflows/build.yml/badge.svg)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgonzalonunez%2Fdocc-gpt%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/gonzalonunez/docc-gpt)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fgonzalonunez%2Fdocc-gpt%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/gonzalonunez/docc-gpt)

https://user-images.githubusercontent.com/6403910/227589893-a1c47996-df5a-4d37-83a8-65bd5c515912.mov

---

DoccGPT is an experiment in fully automating the documentation of a Swift codebase (not quite there yet, but we'll get there, read the FAQ below).

It works by leveraging [OpenAI](https://platform.openai.com/docs/api-reference/completions) and [DocC](https://developer.apple.com/documentation/docc), Apple's documentation compiler:

> The DocC documentation compiler converts Markdown-based text into rich documentation for Swift and Objective-C projects, and displays it right in the Xcode documentation window. You can also host this documentation on a website.

By pairing DoccGPT together with the [Swift Package Index](https://blog.swiftpackageindex.com/posts/auto-generating-auto-hosting-and-auto-updating-docc-documentation/) (which compiles and hosts your documentation for you) you can come very close to a fully self-documenting codebase. DoccGPT writes the markup for you, or at least takes an initial pass at it, and the Swift Package Index takes care of compiling and hosting the generated documentation for you.

All of the markup in `/Sources` was generated by running DoccGPT on itself:

```diff
+ /// A class for running the OpenAI GPT-3 API to document Swift files.
struct DoccGPTRunner {

  // MARK: Internal

+ /// The API key used to authenticate with the OpenAI API.
  let apiKey: String

+  /**
+   Runs the OpenAI GPT-3 API to document Swift files in a directory.
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

Depending on the OpenAI model that it uses, DoccGPT is smart enough to document long and complex Swift code. Simpler models seem to struggle more as the amount of code increases. I have not tried using GPT-4.

## Basic usage

Run the executable and give it a directory as well as your [OpenAI secret key](https://platform.openai.com/account/api-keys).

> **Warning**
> DoccGPT will attempt to rewrite the contents of every single `.swift` file in the directory that you give it. And if you feed it a sufficiently long file it won't make it all the way to the end!

```bash
swift run docc-gpt <directory> --key <key>
```

```bash
ARGUMENTS:
  <directory>             The folder whose contents you want to document

OPTIONS:
  -k, --key <key>         Your secret API key for OpenAI
  -h, --help              Show help information.
```

## How it works

DoccGPT is a command-line tool written in Swift that iterates through all `.swift` files in a given directory and attempts to document your code using [DocC](https://developer.apple.com/documentation/docc) syntax:

> DocC syntax — called documentation markup — is a custom variant of Markdown that adds functionality for developer documentation-specific features, like cross-symbol linking, term-definition lists, code listings, and asides.

At the time of writing, the documentation markup is generated by feeding entire `.swift` files to `/v1/completions`, using the `text-davinci-003` model. The prompt can be found in `prompt.txt` (a few-shot prompt seems to working well). Feeding in entire files seems to result in some pretty impressive behavior, I was surprised by how specific some of the comments in `/Sources/DoccGPT` are and the way in which they reference other parts of the file.

An earlier working version of DoccGPT used the `/edits` endpoint (in beta at the time of writing) and its corresponding Codex model, but `text-davinci-003` seems to be significantly more capable. I have not tried using GPT-4 yet, which I'm sure is even better. It also seems like GPT-4 would get around most of the token-limit issues (see the FAQ below).

## FAQ

#### What's missing?

Number of tokens is an issue, it seems. I was unable to fully document `DoccGPTRunner.swift` because I ran out of tokens. The current token limit, at least the one that `text-davinci-003` has, is not viable for what I would say is the average Swift file. For now, I suppose the solution is to write less code, use GPT-4, or wait until GPT-5 😄

I also haven't figured out what to do about re-running the model on a file that has already been documented. Most of the time, `text-davinci-003` will remove the final newline in the file. With more complex code, sometimes it will make a different decision than the one it had made previously. Perhaps most importantly, I have not figured out how to get it to re-document code if the functionality has changed. All of this can probably be fixed with better prompting or a better model.

Lastly, there is quite a bit of other basic CLI work needed to take this all of the way to a usable state, like exposing the ability to ignore certain files/subdirectories.

#### Would I use this in production?

I am not aware of the privacy implications of sending an entire codebase up to OpenAI's servers, but for that reason alone I would probably not use this.

Assuming we address the privacy implications and the limitations described above, maybe? I would probably avoid auto-committing anything through CI, although `text-davinci-003` seems to be very good at documenting code in a deterministic and high quality way.

That said, I do not think it is far-fetched at all to expect fully automated self-documenting codebases in the near-term future. My current first impressions are that a good prompt goes a long way and that there are huge performance differences between different models / APIs. I'm excited for a future where we can run powerful models locally.

## One more thing...

The curious reader may notice that some of the documentation examples used in the prompt come from the inimitable [NSHipster](https://nshipster.com/swift-documentation/). I'm a longtime fan and tremendous appreciator of everything that NSHipster has done for mobile developers all over the world.
