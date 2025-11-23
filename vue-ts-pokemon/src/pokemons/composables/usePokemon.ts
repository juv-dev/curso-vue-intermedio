import { getPokemonByID } from "../helpers/get-pokemons";
import { useQuery } from "@tanstack/vue-query";

export const usePokemon = (id:string) => {
    
    const {isLoading, data:pokemon, isError, error } = useQuery({
        queryKey: ['pokemon', id],
        queryFn: () => getPokemonByID(id),
    });
    
    return {
        
        //Properties
        pokemon,
        isLoading,
        isError,
        errorMessage:error,

    }
}