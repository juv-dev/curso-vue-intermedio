import { computed, watchEffect} from "vue";
import { getPokemons } from "../helpers/get-pokemons";
import { useQuery } from "@tanstack/vue-query";
import { intialPokemons } from "../data/initial-pokemons";





export const usePokemons = () => {
    
    const {isLoading, data:pokemons, isError, error } = useQuery({
        queryKey: ['pokemons'],
        queryFn: getPokemons,
        initialData: intialPokemons,
        retry: 0,
    });

    watchEffect(() => {
        if ( pokemons.value ) 
            console.log('isError', isError.value);    
    });

    
    return {
        
        //Properties
        pokemons,
        isLoading,
        isError,
        error,


        //Computed
        count: computed(() => pokemons.value?.length ?? 0),

    }
}