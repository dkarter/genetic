# The One-Max Problem
# Q: what is the maximum sum of a bitstring (consisting of 1 and 0) of length N?
#
n = 1_000

population =
  for _ <- 1..100 do
    for _ <- 1..n, do: Enum.random(0..1)
  end

# Evaluate each "chromosome" based on a fitness function (how good or bad the
# solution is).
# Use that evaluation to sort by each chromosome's fitness.
# In this case sort descending, meaning better solutions are grouped together at
# the top.
evaluate = fn population ->
  Enum.sort_by(population, &Enum.sum/1, &>=/2)
end

# Select parents that will be combined to create new solutions (children)
selection = fn population ->
  population
  |> Enum.chunk_every(2)
  |> Enum.map(&List.to_tuple(&1))
end

# create children (new solutions)
# splits each of parent chromosomes at a random point and combines with the
# other parent chromosome until we have a new child chromosome we can pass
# through the algorithm
crossover = fn population ->
  Enum.reduce(population, [], fn {p1, p2}, acc ->
    cx_point = :rand.uniform(n)
    {{h1, t1}, {h2, t2}} = {Enum.split(p1, cx_point), Enum.split(p2, cx_point)}
    [h1 ++ t2, h2 ++ t1 | acc]
  end)
end

# In order to avoid premature convergence (parents getting too similar to make
# any improvements during crossover) we introduce a random mutation to some
# children right after the crossover
mutation = fn population ->
  population
  |> Enum.map(fn chromosome ->
    # The shuffle probability is 5%
    if :rand.uniform() < 0.05 do
      Enum.shuffle(chromosome)
    else
      chromosome
    end
  end)
end

algorithm = fn population, algorithm ->
  best = Enum.max_by(population, &Enum.sum/1)
  IO.inspect(Enum.sum(best), label: "Current best")

  # base-case (termination criteria)
  if Enum.sum(best) == n do
    best
  else
    population
    |> evaluate.()
    |> selection.()
    |> crossover.()
    |> mutation.()
    |> algorithm.(algorithm)
  end
end

solution = algorithm.(population, algorithm)

IO.puts("The answer is:")
IO.inspect(solution)
