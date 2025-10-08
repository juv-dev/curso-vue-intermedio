<script setup lang="ts">
import type { Pokemon } from '../interfaces';
import { useRouter } from 'vue-router';


interface Props {
    pokemon: Pokemon;
}

const props = defineProps<Props>();

const router = useRouter();

const goTo = () => {
    router.push({
      name: 'pokemon-id',
      params: { id: props.pokemon.id }
    })
}

</script>

<template>
    <div class="pokemon-card" @click="goTo">
       <img 
            :src="pokemon.frontSprite" 
            :alt="pokemon.name"  />

        <h3>{{ pokemon.name }}</h3>
       
    </div>

</template>

<style scoped>

.pokemon-card {
  align-items: center;
  cursor: pointer;
  display: flex;
  flex-direction: column;
  margin-bottom: 10px;
  margin-left: 5px;
  margin-right: 5px;
}

img {
  border-radius: 5%;
  box-shadow: 0px 2px 10px rgba(14, 14, 14, 0.1);
  transition: all 0.5s;
  width: 150px;
}

img:hover {
  box-shadow: 0px 2px 10px rgba(0, 0, 0, 0.5);
  transition: all 0.5s;
}


</style>