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

	// Helper to check if any deletion is enabled
	function hasAnyDeletion(): boolean {
		return Boolean(
			flowModule.delete_after_use?.args ||
				flowModule.delete_after_use?.logs ||
				flowModule.delete_after_use?.results
		)
	}

	// Toggle all options on or off
	function toggleAll() {
		if (hasAnyDeletion()) {
			flowModule.delete_after_use = undefined
		} else {
			flowModule.delete_after_use = {
				args: true,
				logs: true,
				results: true
			}
		}
	}

	// Toggle individual options
	function toggleOption(option: 'args' | 'logs' | 'results') {
		if (!flowModule.delete_after_use) {
			flowModule.delete_after_use = {}
		}
		flowModule.delete_after_use[option] = !flowModule.delete_after_use[option]

		// Clean up if all are false
		if (
			!flowModule.delete_after_use.args &&
			!flowModule.delete_after_use.logs &&
			!flowModule.delete_after_use.results
		) {
			flowModule.delete_after_use = undefined
		}
	}
</script>

<Section label="Delete after use">
	{#snippet header()}
		<Tooltip>
			Select which components (arguments, logs, results) should be deleted from Windmill once the
			flow is complete. They might be temporarily visible in UI while the flow is running.
			<br />
			This also applies to a flow step that has failed: the deleted components will not be
			accessible.
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
			checked={hasAnyDeletion()}
			on:change={toggleAll}
			options={{
				right: 'Delete after the flow is complete'
			}}
		/>

		{#if hasAnyDeletion()}
			<div class="ml-6 flex flex-col gap-1.5 text-sm">
				<label class="flex items-center gap-2 cursor-pointer">
					<input
						type="checkbox"
						{disabled}
						checked={Boolean(flowModule.delete_after_use?.args)}
						onchange={() => toggleOption('args')}
						class="rounded"
					/>
					<span>Arguments</span>
				</label>
				<label class="flex items-center gap-2 cursor-pointer">
					<input
						type="checkbox"
						{disabled}
						checked={Boolean(flowModule.delete_after_use?.logs)}
						onchange={() => toggleOption('logs')}
						class="rounded"
					/>
					<span>Logs</span>
				</label>
				<label class="flex items-center gap-2 cursor-pointer">
					<input
						type="checkbox"
						{disabled}
						checked={Boolean(flowModule.delete_after_use?.results)}
						onchange={() => toggleOption('results')}
						class="rounded"
					/>
					<span>Results</span>
				</label>
			</div>
		{/if}
	</div>
</Section>
