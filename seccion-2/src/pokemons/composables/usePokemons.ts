import { computed, watchEffect} from "vue";
import { getPokemons } from "../helpers/get-pokemons";
import { useQuery } from "@tanstack/vue-query";





export const usePokemons = () => {
    
    const {isLoading, data:pokemons, isError, error } = useQuery({
        queryKey: ['pokemons'],
        queryFn: getPokemons,
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