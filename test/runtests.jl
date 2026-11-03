using Test
using Makie
using Makierc

current(block, key) = to_value(Makie.current_default_theme()[block][key])
current(key) = to_value(Makie.current_default_theme()[key])

@testset "load_makie_config!" begin
    @testset "defaults are the package style" begin
        load_makie_config!()
        @test current(:fontsize) == 16
        @test current(:Lines, :linewidth) == 1.8
        @test current(:Scatter, :markersize) == 15
        @test current(:Axis, :xtickalign) == 1
        @test current(:Legend, :framewidth) == 1.5
    end

    @testset "keywords override the matching setting" begin
        load_makie_config!(lw = 2.5, fontsize = 20, markersize = 8)
        @test current(:Lines, :linewidth) == 2.5
        @test current(:Errorbars, :linewidth) == 2.5
        @test current(:VLines, :linewidth) == 2.5
        @test current(:fontsize) == 20
        @test current(:Scatter, :markersize) == 8
    end

    @testset "an override keeps the other settings" begin
        load_makie_config!(fontsize = 20)
        @test current(:Lines, :linewidth) == 1.8
        @test current(:Axis, :xticksmirrored) == true
    end

    @testset "a new call does not remember the previous one" begin
        load_makie_config!(lw = 2.5)
        load_makie_config!()
        @test current(:Lines, :linewidth) == 1.8
    end

    @testset "k_ideal sets the tick target" begin
        load_makie_config!(k_ideal = 7)
        @test current(:Axis, :xticks).k_ideal == 7
        @test current(:Axis, :yticks).k_ideal == 7
    end

    @testset "palette and figure_padding are opt-in" begin
        load_makie_config!(figure_padding = 30, palette = Makierc.MPL_PALETTE)
        @test current(:figure_padding) == 30
        @test to_value(current(:palette)[:color]) == Makierc.MPL_PALETTE.color
    end

    @testset "misspelled keywords raise an error" begin
        @test_throws MethodError load_makie_config!(linewidth_typo = 2)
    end
end
