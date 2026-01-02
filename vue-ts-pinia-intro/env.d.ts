/// <reference types="vite/client" />

declare module '*.vue' {
	import type { DefineComponent } from 'vue'
	const component: DefineComponent<{}, {}, any>
	export default component
}

interface ImportMetaEnv {
	readonly VITE_API_URL: string;
	// Agrega aquí otras variables de entorno que necesites
}
interface ImportMeta {
	readonly env: ImportMetaEnv;
}