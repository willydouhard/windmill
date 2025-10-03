<script lang="ts">
	import Toggle from '$lib/components/Toggle.svelte'
	import Tooltip from '$lib/components/Tooltip.svelte'
	import type { FlowModule } from '$lib/gen'

	import Section from '$lib/components/Section.svelte'

	interface Props {
		flowModule: FlowModule
		disabled?: boolean
	}

	let { flowModule = $bindable(), disabled = false }: Props = $props()

	// Helper to check if delete_after_use is enabled (handles both boolean and object format)
	function isDeleteAfterUseEnabled(): boolean {
		if (!flowModule.delete_after_use) return false
		if (typeof flowModule.delete_after_use === 'boolean') return flowModule.delete_after_use
		return flowModule.delete_after_use.args || flowModule.delete_after_use.logs || flowModule.delete_after_use.results
	}

	// Helper to ensure delete_after_use is an object
	function ensureDeleteAfterUseObject() {
		if (!flowModule.delete_after_use) {
			flowModule.delete_after_use = { args: false, logs: false, results: false }
		} else if (typeof flowModule.delete_after_use === 'boolean') {
			const enabled = flowModule.delete_after_use
			flowModule.delete_after_use = { args: enabled, logs: enabled, results: enabled }
		}
	}

	function toggleMainOption() {
		if (flowModule.delete_after_use) {
			flowModule.delete_after_use = undefined
		} else {
			flowModule.delete_after_use = { args: true, logs: true, results: true }
		}
	}

	function toggleSubOption(field: 'args' | 'logs' | 'results') {
		ensureDeleteAfterUseObject()
		if (typeof flowModule.delete_after_use === 'object') {
			flowModule.delete_after_use[field] = !flowModule.delete_after_use[field]
		}
	}

	function getSubOptionValue(field: 'args' | 'logs' | 'results'): boolean {
		if (!flowModule.delete_after_use) return false
		if (typeof flowModule.delete_after_use === 'boolean') return flowModule.delete_after_use
		return flowModule.delete_after_use[field] || false
	}
</script>

<Section label="Delete after use">
	{#snippet header()}
		<Tooltip>
			Select which data to delete after the flow is complete. Deleted data will be completely removed from Windmill
			once the flow is complete. Data might be temporarily visible in UI while the flow is running.
			<br />
			This also applies to a flow step that has failed: the error will not be accessible if results are deleted.
			<br />
			<br />
			The deletion is irreversible.
			{#if disabled}
				<br />
				<br />
				This option is only available on Windmill Enterprise Edition.
			{/if}
		</Tooltip>
	{/snippet}

	<div class="flex flex-col gap-2">
		<Toggle
			{disabled}
			size="sm"
			checked={isDeleteAfterUseEnabled()}
			on:change={toggleMainOption}
			options={{
				right: 'Delete after the flow is complete'
			}}
		/>

		{#if isDeleteAfterUseEnabled()}
			<div class="ml-6 flex flex-col gap-1 mt-2">
				<Toggle
					{disabled}
					size="xs"
					checked={getSubOptionValue('args')}
					on:change={() => toggleSubOption('args')}
					options={{
						right: 'Delete arguments'
					}}
				/>
				<Toggle
					{disabled}
					size="xs"
					checked={getSubOptionValue('logs')}
					on:change={() => toggleSubOption('logs')}
					options={{
						right: 'Delete logs'
					}}
				/>
				<Toggle
					{disabled}
					size="xs"
					checked={getSubOptionValue('results')}
					on:change={() => toggleSubOption('results')}
					options={{
						right: 'Delete results'
					}}
				/>
			</div>
		{/if}
	</div>
</Section>
