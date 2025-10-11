<script lang="ts">
	import Toggle from '$lib/components/Toggle.svelte'
	import Tooltip from '$lib/components/Tooltip.svelte'
	import type { FlowModule } from '$lib/gen'

	import Section from '$lib/components/Section.svelte'
	import { Checkbox } from '$lib/components/common'

	interface Props {
		flowModule: FlowModule
		disabled?: boolean
	}

	let { flowModule = $bindable(), disabled = false }: Props = $props()

	// Track granular delete options
	let showGranular = $state(false)
	let deleteArgs = $state(true)
	let deleteLogs = $state(true)
	let deleteResult = $state(true)

	// Initialize state based on current value
	$effect(() => {
		if (flowModule.delete_after_use === true || flowModule.delete_after_use === false) {
			// Legacy boolean format
			showGranular = false
			deleteArgs = flowModule.delete_after_use
			deleteLogs = flowModule.delete_after_use
			deleteResult = flowModule.delete_after_use
		} else if (
			flowModule.delete_after_use &&
			typeof flowModule.delete_after_use === 'object'
		) {
			// Granular format
			showGranular = true
			deleteArgs = flowModule.delete_after_use.args ?? false
			deleteLogs = flowModule.delete_after_use.logs ?? false
			deleteResult = flowModule.delete_after_use.result ?? false
		} else {
			showGranular = false
			deleteArgs = false
			deleteLogs = false
			deleteResult = false
		}
	})

	function toggleDeleteAfterUse() {
		const isEnabled = Boolean(flowModule.delete_after_use)
		if (isEnabled) {
			flowModule.delete_after_use = undefined
		} else {
			if (showGranular) {
				flowModule.delete_after_use = {
					args: deleteArgs,
					logs: deleteLogs,
					result: deleteResult
				}
			} else {
				flowModule.delete_after_use = true
			}
		}
	}

	function updateGranularOptions() {
		if (showGranular) {
			flowModule.delete_after_use = {
				args: deleteArgs,
				logs: deleteLogs,
				result: deleteResult
			}
		} else {
			flowModule.delete_after_use = deleteArgs || deleteLogs || deleteResult ? true : undefined
		}
	}
</script>

<Section label="Delete after use">
	{#snippet header()}
		<Tooltip>
			Control what data gets deleted from Windmill once the flow is complete.
			<br />
			You can choose to delete:
			<ul>
				<li><strong>Args</strong>: The input arguments passed to this step</li>
				<li><strong>Logs</strong>: The execution logs</li>
				<li><strong>Result</strong>: The output result</li>
			</ul>
			Data might be temporarily visible in UI while the flow is running.
			<br />
			This also applies to failed flow steps: the error will not be accessible if result is deleted.
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
			checked={Boolean(flowModule.delete_after_use)}
			on:change={toggleDeleteAfterUse}
			options={{
				right: 'Delete data after the flow is complete'
			}}
		/>

		{#if flowModule.delete_after_use}
			<div class="ml-4 flex flex-col gap-1 border-l-2 border-gray-300 pl-3">
				<label class="flex items-center gap-2 text-xs cursor-pointer">
					<Checkbox
						size="xs"
						bind:checked={showGranular}
						on:change={() => {
							if (!showGranular) {
								// Switching to simple mode - reset to all true
								deleteArgs = true
								deleteLogs = true
								deleteResult = true
							}
							updateGranularOptions()
						}}
					/>
					<span>Granular control</span>
				</label>

				{#if showGranular}
					<div class="flex flex-col gap-1 ml-4">
						<label class="flex items-center gap-2 text-xs cursor-pointer">
							<Checkbox
								size="xs"
								bind:checked={deleteArgs}
								on:change={updateGranularOptions}
							/>
							<span>Delete arguments</span>
						</label>
						<label class="flex items-center gap-2 text-xs cursor-pointer">
							<Checkbox
								size="xs"
								bind:checked={deleteLogs}
								on:change={updateGranularOptions}
							/>
							<span>Delete logs</span>
						</label>
						<label class="flex items-center gap-2 text-xs cursor-pointer">
							<Checkbox
								size="xs"
								bind:checked={deleteResult}
								on:change={updateGranularOptions}
							/>
							<span>Delete result</span>
						</label>
					</div>
				{/if}
			</div>
		{/if}
	</div>
</Section>
