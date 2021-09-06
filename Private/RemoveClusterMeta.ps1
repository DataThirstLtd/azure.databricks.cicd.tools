function RemoveClusterMeta{
    [CmdletBinding()]
    param (
        [hashtable]$hashtable
    )

    $hashtable.Remove('creator_user_name')
    $hashtable.Remove('termination_reason')
    $hashtable.Remove('state')
    $hashtable.Remove('terminated_time')
    $hashtable.Remove('start_time')
    $hashtable.Remove('state_message')
    $hashtable.Remove('cluster_log_status')
    $hashtable.Remove('spark_context_id')
    $hashtable.Remove('last_state_loss_time')
    $hashtable.Remove('init_scripts_safe_mode')
    $hashtable.Remove('cluster_source')

    return $hashtable
}