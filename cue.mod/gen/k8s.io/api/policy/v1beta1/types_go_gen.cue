// Code generated by cue get go. DO NOT EDIT.

//cue:generate cue get go k8s.io/api/policy/v1beta1

package v1beta1

import (
	"k8s.io/apimachinery/pkg/util/intstr"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
)

// PodDisruptionBudgetSpec is a description of a PodDisruptionBudget.
#PodDisruptionBudgetSpec: {
	// An eviction is allowed if at least "minAvailable" pods selected by
	// "selector" will still be available after the eviction, i.e. even in the
	// absence of the evicted pod.  So for example you can prevent all voluntary
	// evictions by specifying "100%".
	// +optional
	minAvailable?: null | intstr.#IntOrString @go(MinAvailable,*intstr.IntOrString) @protobuf(1,bytes,opt)

	// Label query over pods whose evictions are managed by the disruption
	// budget.
	// A null selector selects no pods.
	// An empty selector ({}) also selects no pods, which differs from standard behavior of selecting all pods.
	// In policy/v1, an empty selector will select all pods in the namespace.
	// +optional
	selector?: null | metav1.#LabelSelector @go(Selector,*metav1.LabelSelector) @protobuf(2,bytes,opt)

	// An eviction is allowed if at most "maxUnavailable" pods selected by
	// "selector" are unavailable after the eviction, i.e. even in absence of
	// the evicted pod. For example, one can prevent all voluntary evictions
	// by specifying 0. This is a mutually exclusive setting with "minAvailable".
	// +optional
	maxUnavailable?: null | intstr.#IntOrString @go(MaxUnavailable,*intstr.IntOrString) @protobuf(3,bytes,opt)

	// UnhealthyPodEvictionPolicy defines the criteria for when unhealthy pods
	// should be considered for eviction. Current implementation considers healthy pods,
	// as pods that have status.conditions item with type="Ready",status="True".
	//
	// Valid policies are IfHealthyBudget and AlwaysAllow.
	// If no policy is specified, the default behavior will be used,
	// which corresponds to the IfHealthyBudget policy.
	//
	// IfHealthyBudget policy means that running pods (status.phase="Running"),
	// but not yet healthy can be evicted only if the guarded application is not
	// disrupted (status.currentHealthy is at least equal to status.desiredHealthy).
	// Healthy pods will be subject to the PDB for eviction.
	//
	// AlwaysAllow policy means that all running pods (status.phase="Running"),
	// but not yet healthy are considered disrupted and can be evicted regardless
	// of whether the criteria in a PDB is met. This means perspective running
	// pods of a disrupted application might not get a chance to become healthy.
	// Healthy pods will be subject to the PDB for eviction.
	//
	// Additional policies may be added in the future.
	// Clients making eviction decisions should disallow eviction of unhealthy pods
	// if they encounter an unrecognized policy in this field.
	//
	// This field is beta-level. The eviction API uses this field when
	// the feature gate PDBUnhealthyPodEvictionPolicy is enabled (enabled by default).
	// +optional
	unhealthyPodEvictionPolicy?: null | #UnhealthyPodEvictionPolicyType @go(UnhealthyPodEvictionPolicy,*UnhealthyPodEvictionPolicyType) @protobuf(4,bytes,opt)
}

// UnhealthyPodEvictionPolicyType defines the criteria for when unhealthy pods
// should be considered for eviction.
// +enum
#UnhealthyPodEvictionPolicyType: string // #enumUnhealthyPodEvictionPolicyType

#enumUnhealthyPodEvictionPolicyType:
	#IfHealthyBudget |
	#AlwaysAllow

// IfHealthyBudget policy means that running pods (status.phase="Running"),
// but not yet healthy can be evicted only if the guarded application is not
// disrupted (status.currentHealthy is at least equal to status.desiredHealthy).
// Healthy pods will be subject to the PDB for eviction.
#IfHealthyBudget: #UnhealthyPodEvictionPolicyType & "IfHealthyBudget"

// AlwaysAllow policy means that all running pods (status.phase="Running"),
// but not yet healthy are considered disrupted and can be evicted regardless
// of whether the criteria in a PDB is met. This means perspective running
// pods of a disrupted application might not get a chance to become healthy.
// Healthy pods will be subject to the PDB for eviction.
#AlwaysAllow: #UnhealthyPodEvictionPolicyType & "AlwaysAllow"

// PodDisruptionBudgetStatus represents information about the status of a
// PodDisruptionBudget. Status may trail the actual state of a system.
#PodDisruptionBudgetStatus: {
	// Most recent generation observed when updating this PDB status. DisruptionsAllowed and other
	// status information is valid only if observedGeneration equals to PDB's object generation.
	// +optional
	observedGeneration?: int64 @go(ObservedGeneration) @protobuf(1,varint,opt)

	// DisruptedPods contains information about pods whose eviction was
	// processed by the API server eviction subresource handler but has not
	// yet been observed by the PodDisruptionBudget controller.
	// A pod will be in this map from the time when the API server processed the
	// eviction request to the time when the pod is seen by PDB controller
	// as having been marked for deletion (or after a timeout). The key in the map is the name of the pod
	// and the value is the time when the API server processed the eviction request. If
	// the deletion didn't occur and a pod is still there it will be removed from
	// the list automatically by PodDisruptionBudget controller after some time.
	// If everything goes smooth this map should be empty for the most of the time.
	// Large number of entries in the map may indicate problems with pod deletions.
	// +optional
	disruptedPods?: {[string]: metav1.#Time} @go(DisruptedPods,map[string]metav1.Time) @protobuf(2,bytes,rep)

	// Number of pod disruptions that are currently allowed.
	disruptionsAllowed: int32 @go(DisruptionsAllowed) @protobuf(3,varint,opt)

	// current number of healthy pods
	currentHealthy: int32 @go(CurrentHealthy) @protobuf(4,varint,opt)

	// minimum desired number of healthy pods
	desiredHealthy: int32 @go(DesiredHealthy) @protobuf(5,varint,opt)

	// total number of pods counted by this disruption budget
	expectedPods: int32 @go(ExpectedPods) @protobuf(6,varint,opt)

	// Conditions contain conditions for PDB. The disruption controller sets the
	// DisruptionAllowed condition. The following are known values for the reason field
	// (additional reasons could be added in the future):
	// - SyncFailed: The controller encountered an error and wasn't able to compute
	//               the number of allowed disruptions. Therefore no disruptions are
	//               allowed and the status of the condition will be False.
	// - InsufficientPods: The number of pods are either at or below the number
	//                     required by the PodDisruptionBudget. No disruptions are
	//                     allowed and the status of the condition will be False.
	// - SufficientPods: There are more pods than required by the PodDisruptionBudget.
	//                   The condition will be True, and the number of allowed
	//                   disruptions are provided by the disruptionsAllowed property.
	//
	// +optional
	// +patchMergeKey=type
	// +patchStrategy=merge
	// +listType=map
	// +listMapKey=type
	conditions?: [...metav1.#Condition] @go(Conditions,[]metav1.Condition) @protobuf(7,bytes,rep)
}

// DisruptionAllowedCondition is a condition set by the disruption controller
// that signal whether any of the pods covered by the PDB can be disrupted.
#DisruptionAllowedCondition: "DisruptionAllowed"

// SyncFailedReason is set on the DisruptionAllowed condition if reconcile
// of the PDB failed and therefore disruption of pods are not allowed.
#SyncFailedReason: "SyncFailed"

// SufficientPodsReason is set on the DisruptionAllowed condition if there are
// more pods covered by the PDB than required and at least one can be disrupted.
#SufficientPodsReason: "SufficientPods"

// InsufficientPodsReason is set on the DisruptionAllowed condition if the number
// of pods are equal to or fewer than required by the PDB.
#InsufficientPodsReason: "InsufficientPods"

// PodDisruptionBudget is an object to define the max disruption that can be caused to a collection of pods
#PodDisruptionBudget: {
	metav1.#TypeMeta

	// Standard object's metadata.
	// More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
	// +optional
	metadata?: metav1.#ObjectMeta @go(ObjectMeta) @protobuf(1,bytes,opt)

	// Specification of the desired behavior of the PodDisruptionBudget.
	// +optional
	spec?: #PodDisruptionBudgetSpec @go(Spec) @protobuf(2,bytes,opt)

	// Most recently observed status of the PodDisruptionBudget.
	// +optional
	status?: #PodDisruptionBudgetStatus @go(Status) @protobuf(3,bytes,opt)
}

// PodDisruptionBudgetList is a collection of PodDisruptionBudgets.
#PodDisruptionBudgetList: {
	metav1.#TypeMeta

	// Standard object's metadata.
	// More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata
	// +optional
	metadata?: metav1.#ListMeta @go(ListMeta) @protobuf(1,bytes,opt)

	// items list individual PodDisruptionBudget objects
	items: [...#PodDisruptionBudget] @go(Items,[]PodDisruptionBudget) @protobuf(2,bytes,rep)
}

// Eviction evicts a pod from its node subject to certain policies and safety constraints.
// This is a subresource of Pod.  A request to cause such an eviction is
// created by POSTing to .../pods/<pod name>/evictions.
#Eviction: {
	metav1.#TypeMeta

	// ObjectMeta describes the pod that is being evicted.
	// +optional
	metadata?: metav1.#ObjectMeta @go(ObjectMeta) @protobuf(1,bytes,opt)

	// DeleteOptions may be provided
	// +optional
	deleteOptions?: null | metav1.#DeleteOptions @go(DeleteOptions,*metav1.DeleteOptions) @protobuf(2,bytes,opt)
}
