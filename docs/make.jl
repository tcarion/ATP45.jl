using ATP45
using Documenter

DocMeta.setdocmeta!(ATP45, :DocTestSetup, :(using ATP45); recursive=true)

makedocs(;
    modules=[ATP45],
    authors="tcarion <tristancarion@gmail.com> and contributors",
    repo="https://github.com/tcarion/ATP45.jl/blob/{commit}{path}#{line}",
    sitename="ATP45.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://tcarion.github.io/ATP45.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tcarion/ATP45.jl",
    devbranch="main",
)
