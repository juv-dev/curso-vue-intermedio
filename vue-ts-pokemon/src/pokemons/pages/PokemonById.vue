<script setup lang="ts">
import { useRoute } from 'vue-router';
import { usePokemon } from '../composables/usePokemon';
import { useQueryClient } from '@tanstack/vue-query';

const route = useRoute();
const queryClient = useQueryClient();

const { id } = route.params;

const { isLoading, pokemon, isError, errorMessage } = usePokemon(id.toString());

const invalidateQueries = () => {
	queryClient.invalidateQueries({
		queryKey: ['pokemon', id],
	});
}

</script>

<template>

	<button @click="invalidateQueries">Invalidar queries</button>

	<h1 v-if="isLoading">Loading..</h1>
	<h1 v-else-if="isError">{{ errorMessage }}</h1>
	<div v-else-if="pokemon">
		<h1>{{ pokemon.name }}</h1>
		<div class="character-container">
			<img :src="pokemon.frontSprite" :alt="pokemon.name" />
		</div>
	</div>
</template>

<style scoped>
.character-container {
	display: flex;
	justify-content: center;
	align-items: center;
}
</style>
