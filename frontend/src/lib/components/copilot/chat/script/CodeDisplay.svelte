<script lang="ts">
	import { getAstNode } from 'svelte-exmarkdown'
	import HighlightCode from '$lib/components/HighlightCode.svelte'
	import {
		csharp,
		go,
		graphql,
		javascript,
		php,
		python,
		rust,
		shell,
		sql,
		typescript,
		yaml
	} from 'svelte-highlight/languages'
	import { Button } from '$lib/components/common'
	import { CheckIcon } from 'lucide-svelte'
	import { aiChatManager } from '../AIChatManager.svelte'
	import type { ScriptLang } from '$lib/gen/types.gen'

	const astNode = getAstNode()

	function getSmartLang(lang: string) {
		switch (lang) {
			case 'python':
			case 'python3':
				return 'python'
			case 'deno':
			case 'nativets':
			case 'bun':
			case 'bunnative':
			case 'typescript':
				return 'typescript'
			case 'go':
				return 'go'
			case 'shell':
			case 'bash':
				return 'shell'
			case 'frontend':
			case 'javascript':
				return 'javascript'
			case 'graphql':
				return 'graphql'
			case 'mysql':
			case 'snowflake':
			case 'bigquery':
			case 'oracledb':
			case 'powershell':
			case 'postgresql':
			case 'sql':
				return 'sql'
			case 'php':
				return 'php'
			case 'rust':
				return 'rust'
			case 'csharp':
				return 'csharp'
			case 'ansible':
			case 'yaml':
				return 'yaml'
			default:
				return 'typescript'
		}
	}

	const SMART_LANG_TO_HIGHLIGHT_LANG = {
		python: python,
		typescript: typescript,
		go: go,
		shell: shell,
		javascript: javascript,
		graphql: graphql,
		sql: sql,
		php: php,
		rust: rust,
		csharp: csharp,
		yaml: yaml
	}

	// Map smart language to script language for comparison
	function getScriptLang(smartLang: string): ScriptLang | 'bunnative' | null {
		switch (smartLang) {
			case 'python':
				return 'python3'
			case 'typescript':
				return 'bun' // Could also be deno, nativets, bunnative - we'll handle this below
			case 'go':
				return 'go'
			case 'shell':
				return 'bash'
			case 'javascript':
				return 'bun'
			case 'graphql':
				return 'graphql'
			case 'sql':
				return 'postgresql' // Could be mysql, bigquery, etc - we'll handle this below
			case 'php':
				return 'php'
			case 'rust':
				return 'rust'
			case 'csharp':
				return 'csharp'
			default:
				return null
		}
	}

	// Check if the code block language matches the editor language
	function isLanguageMatch(codeLanguage: string | undefined, editorLang: ScriptLang | 'bunnative'): boolean {
		if (!codeLanguage) return false

		const smartLang = getSmartLang(codeLanguage)
		const scriptLang = getScriptLang(smartLang)

		if (!scriptLang) return false

		// TypeScript variants all match
		if (['bun', 'deno', 'nativets', 'bunnative'].includes(editorLang) && smartLang === 'typescript') {
			return true
		}

		// SQL variants all match
		if (['postgresql', 'mysql', 'bigquery', 'snowflake', 'mssql'].includes(editorLang) && smartLang === 'sql') {
			return true
		}

		return scriptLang === editorLang
	}

	let code = $derived(astNode.current.children?.[0]?.children?.[0]?.value)

	let language = $derived(
		(astNode.current.children?.[0]?.properties?.class as string | undefined)?.split('-')[1]
	)

	// Show apply button if we can apply code and the language matches
	let canApplyCode = $derived(
		aiChatManager.canApplyCode &&
		code &&
		aiChatManager.scriptEditorOptions?.lang &&
		isLanguageMatch(language, aiChatManager.scriptEditorOptions.lang)
	)

	function applyCode() {
		if (code && aiChatManager.scriptEditorApplyCode) {
			aiChatManager.scriptEditorApplyCode(code, { applyAll: true, mode: 'apply' })
		}
	}
</script>

<div
	class="flex flex-col not-prose relative w-full border border-gray-300 dark:border-gray-600 rounded-lg overflow-hidden"
>
	{#if canApplyCode}
		<div class="flex justify-end border-b border-gray-300 dark:border-gray-600 bg-surface-secondary px-2 py-1">
			<Button
				size="xs2"
				variant="border"
				color="blue"
				startIcon={{ icon: CheckIcon }}
				on:click={applyCode}
			>
				Apply
			</Button>
		</div>
	{/if}
	<HighlightCode
		class="p-1"
		code={code ?? ''}
		highlightLanguage={SMART_LANG_TO_HIGHLIGHT_LANG[getSmartLang(language as string)]}
		language={undefined}
	/>
</div>
