using Documenter, ATP45, Plots

ENV["GKSwstype"] = "100"

# Plots warnings are brWarn doctests. They dont warn the second time.
function flush_info_and_warnings()
    r = run_atp("simplified", "chem", ReleaseLocations([4.,50.]), WindAzimuth(2., 45.))
    plot(r)
end
flush_info_and_warnings()

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
        "Internals" => "internals.md",
    ],
)

deploydocs(;
    repo="github.com/tcarion/ATP45.jl",
    devbranch="main",
)
