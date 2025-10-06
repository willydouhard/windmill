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

	// Helper to check if delete_after_use is enabled
	let isEnabled = $derived(
		flowModule.delete_after_use !== undefined && flowModule.delete_after_use !== null
	)

	// Helper to get current options (handling both boolean and object formats)
	let currentOptions = $derived(() => {
		if (!flowModule.delete_after_use) {
			return { args: false, logs: false, results: false }
		}
		if (typeof flowModule.delete_after_use === 'boolean') {
			// Legacy boolean format
			return { args: true, logs: true, results: true }
		}
		// New object format
		return {
			args: flowModule.delete_after_use.args ?? false,
			logs: flowModule.delete_after_use.logs ?? false,
			results: flowModule.delete_after_use.results ?? false
		}
	})

	function toggleMain() {
		if (flowModule.delete_after_use) {
			flowModule.delete_after_use = undefined
		} else {
			flowModule.delete_after_use = { args: true, logs: true, results: true }
		}
	}

	function updateOption(field: 'args' | 'logs' | 'results', value: boolean) {
		if (typeof flowModule.delete_after_use === 'boolean' || !flowModule.delete_after_use) {
			// Convert to object format
			flowModule.delete_after_use = {
				args: field === 'args' ? value : false,
				logs: field === 'logs' ? value : false,
				results: field === 'results' ? value : false
			}
		} else {
			// Update existing object
			flowModule.delete_after_use = {
				...flowModule.delete_after_use,
				[field]: value
			}
		}
	}
</script>

<Section label="Delete after use">
	{#snippet header()}
		<Tooltip>
			Control what data gets deleted for this flow step after the flow is complete. Data might be
			temporarily visible in UI while the flow is running.
			<br />
			This also applies to a flow step that has failed: the error will not be accessible if results
			are deleted.
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
			checked={isEnabled}
			on:change={toggleMain}
			options={{
				right: 'Delete data after the flow is complete'
			}}
		/>

		{#if isEnabled}
			<div class="flex flex-col gap-1 ml-4 mt-1">
				<Toggle
					{disabled}
					size="xs"
					checked={currentOptions().args}
					on:change={() => updateOption('args', !currentOptions().args)}
					options={{
						right: 'Delete arguments (inputs to this step)'
					}}
				/>
				<Toggle
					{disabled}
					size="xs"
					checked={currentOptions().logs}
					on:change={() => updateOption('logs', !currentOptions().logs)}
					options={{
						right: 'Delete logs'
					}}
				/>
				<Toggle
					{disabled}
					size="xs"
					checked={currentOptions().results}
					on:change={() => updateOption('results', !currentOptions().results)}
					options={{
						right: 'Delete results (outputs from this step)'
					}}
				/>
			</div>
		{/if}
	</div>
</Section>
