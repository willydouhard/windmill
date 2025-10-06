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

	// Helper to get the current config or default
	function getConfig() {
		if (!flowModule.delete_after_use) {
			return { args: false, logs: false, results: false }
		}
		if (typeof flowModule.delete_after_use === 'boolean') {
			// Backward compatibility: convert old boolean to new config
			return flowModule.delete_after_use
				? { args: true, logs: true, results: true }
				: { args: false, logs: false, results: false }
		}
		return {
			args: flowModule.delete_after_use.args ?? false,
			logs: flowModule.delete_after_use.logs ?? false,
			results: flowModule.delete_after_use.results ?? false
		}
	}

	// Helper to update the config
	function updateConfig(field: 'args' | 'logs' | 'results', value: boolean) {
		const config = getConfig()
		config[field] = value

		// If all are false, set to undefined
		if (!config.args && !config.logs && !config.results) {
			flowModule.delete_after_use = undefined
		} else {
			flowModule.delete_after_use = config
		}
	}

	// Check if any deletion is enabled
	function hasAnyDeletion() {
		const config = getConfig()
		return config.args || config.logs || config.results
	}
</script>

<Section label="Delete after use">
	{#snippet header()}
		<Tooltip>
			Configure which data to delete from Windmill once the flow is complete. Data might be
			temporarily visible in UI while the flow is running.
			<br />
			<br />
			This also applies to a flow step that has failed: deleted data will not be accessible.
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
			checked={getConfig().args}
			on:change={() => {
				updateConfig('args', !getConfig().args)
			}}
			options={{
				right: 'Delete arguments'
			}}
		/>
		<div class="text-xs text-gray-600 ml-6 -mt-1">
			Remove the input arguments passed to this step
		</div>

		<Toggle
			{disabled}
			size="sm"
			checked={getConfig().logs}
			on:change={() => {
				updateConfig('logs', !getConfig().logs)
			}}
			options={{
				right: 'Delete logs'
			}}
		/>
		<div class="text-xs text-gray-600 ml-6 -mt-1">Remove the execution logs from this step</div>

		<Toggle
			{disabled}
			size="sm"
			checked={getConfig().results}
			on:change={() => {
				updateConfig('results', !getConfig().results)
			}}
			options={{
				right: 'Delete results'
			}}
		/>
		<div class="text-xs text-gray-600 ml-6 -mt-1">Remove the output result from this step</div>
	</div>
</Section>
