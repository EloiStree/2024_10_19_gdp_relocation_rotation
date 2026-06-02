#See  https://github.com/EloiStree/2024_10_19_upm_relocation_rotation
class_name RelocateRotationUtility
extends Node

class RefToVector3Quaternion:
	var vector3: Vector3
	var quaternion: Quaternion

class RefToVector3:
	var vector3: Vector3

class RefToQuaternion:
	var quaternion: Quaternion

#region ROTATE AROUND PIVOT

static func rotate_point_around_pivot(point: Vector3, pivot: Vector3, euler_angles: Vector3) -> Vector3:
	# UNITY CODE #         
	#public static Vector3 RotatePointAroundPivot(Vector3 point, Vector3 pivot, Vector3 angles)
	#         {
	#             return RotatePointAroundPivot(point, pivot, Quaternion.Euler(angles));
	#         }

	var rotation = Quaternion.from_euler(euler_angles)
	return rotate_point_around_pivot(point, pivot, rotation)

#static func rotate_point_around_pivot(point: Vector3, pivot: Vector3, rotation: Quaternion, out_point_rotated: RefToVector3):
	###         public static Vector3 RotatePointAroundPivot(Vector3 point, Vector3 pivot, Quaternion rotation)
	##         {
	##             return rotation * (point - pivot) + pivot;
	##         }
#
	#out_point_rotated.vector3 = rotation * (point - pivot) + pivot



#endregion

#region WORLD TO LOCAL
static func get_world_to_local_point_from_root_position_rotation(world_position: Vector3, position_reference: Vector3, rotation_reference: Quaternion) -> Vector3:
	# UNITY CODE
	#         public static void GetWorldToLocal_Point(in Vector3 worldPosition, in Vector3 positionReference, in Quaternion rotationReference, out Vector3 localPosition) =>
	#         localPosition = Quaternion.Inverse(rotationReference) * (worldPosition - positionReference);
	return rotation_reference.inverse() * (world_position - position_reference)


static func get_world_to_local_point_from_root_reference(world_position: Vector3, root_reference: Node3D) -> Vector3:
	var position_reference = root_reference.global_transform.origin
	var rotation_reference = root_reference.global_transform.basis.get_quaternion()
	return get_world_to_local_point_from_root_position_rotation(world_position, position_reference, rotation_reference)



#endregion


#region RELOCATE: POINT
static func get_local_to_world_point_from_root_position_rotation(local_position: Vector3, position_reference: Vector3, rotation_reference: Quaternion) -> Vector3:
	# UNITY CODE
	#         public static void GetLocalToWorld_Point(in Vector3 localPosition, in Vector3 positionReference, in Quaternion rotationReference, out Vector3 worldPosition) =>
	#             worldPosition = (rotationReference * localPosition) + (positionReference);
	return (rotation_reference * local_position) + position_reference


static func get_local_to_world_point_from_root_reference(local_position: Vector3, root_reference: Node3D) -> Vector3:
	var position_reference = root_reference.global_transform.origin
	var rotation_reference = root_reference.global_transform.basis.get_quaternion()
	return get_local_to_world_point_from_root_position_rotation(local_position, position_reference, rotation_reference)

#endregion


#region RELOCATE: DIRECTION AND POINT
#region LOCAL TO WORLD
static func get_local_to_world_direction_and_point_from_root_position_rotation(
	local_position: Vector3,
	local_rotation: Quaternion,
	position_reference: RefToVector3,
	rotation_reference: RefToQuaternion)->void:
	# IN UNITY THIS IS THE CODE
	#         public static void GetLocalToWorld_DirectionalPoint(in Vector3 localPosition, in Quaternion localRotation, in Vector3 positionReference, in Quaternion rotationReference, out Vector3 worldPosition, out Quaternion worldRotation)
	#         {
	#             /// I need to verify the commutativity of this code. 
	#             /// I think it was ok then had a bug in a game link to this methode and thr commutative property
	#             worldRotation = rotationReference * localRotation;
	#             worldPosition = (rotationReference * localPosition) + (positionReference);
	#         }
	var world_rotation = rotation_reference.quaternion * local_rotation
	var world_position = (rotation_reference.quaternion * local_position) + position_reference.vector3
	position_reference.vector3 = RefToVector3(world_position) 
	rotation_reference.quaternion = RefToQuaternion(world_rotation)


static func get_local_to_world_direction_and_point_from_root_reference(
	local_position: Vector3,
	local_rotation: Quaternion,
	root_reference: Node3D,
	position_reference: RefToVector3,
	rotation_reference: RefToQuaternion)->void:
	var position_ref = root_reference.global_transform.origin
	var rotation_ref = root_reference.global_transform.basis.get_quaternion()
	get_local_to_world_direction_and_point_from_root_position_rotation(local_position, local_rotation, RefToVector3(position_ref), RefToQuaternion(rotation_ref), position_reference, rotation_reference)
#endregion
#region WORLD TO LOCAL

static func get_world_to_local_direction_and_point_from_root_position_rotation(
	world_position: Vector3,
	world_rotation: Quaternion,
	position_reference: RefToVector3,
	rotation_reference: RefToQuaternion)->void:
	var local_rotation = rotation_reference.quaternion.inverse() * world_rotation
	var local_position = rotation_reference.quaternion.inverse() * (world_position - position_reference.vector3)
	position_reference.vector3 = RefToVector3(local_position) 
	rotation_reference.quaternion = RefToQuaternion(local_rotation)

static func get_world_to_local_direction_and_point_from_root_reference(
	world_position: Vector3,
	world_rotation: Quaternion,
	root_reference: Node3D,
	position_reference: RefToVector3,
	rotation_reference: RefToQuaternion)->void:
	var position_ref = root_reference.global_transform.origin
	var rotation_ref = root_reference.global_transform.basis.get_quaternion()
	get_world_to_local_direction_and_point_from_root_position_rotation(world_position, world_rotation, RefToVector3(position_ref), RefToQuaternion(rotation_ref), position_reference, rotation_reference)


#endregion
#endregion






# using UnityEngine;

# namespace Eloi
# {

#     public class RelocationUtility
#     {

#        
#           public static void GetWorldToLocal_Point(in Vector3 worldPosition, in Transform rootReference, out Vector3 localPosition)
#         {
#             Vector3 p = rootReference.position;
#             Quaternion r = rootReference.rotation;
#             GetWorldToLocal_Point(in worldPosition, in p, in r, out localPosition);
#         }
#         public static void GetLocalToWorld_Point(in Vector3 localPosition, in Transform rootReference, out Vector3 worldPosition)
#         {
#             Vector3 p = rootReference.position;
#             Quaternion r = rootReference.rotation;
#             GetLocalToWorld_Point(in localPosition, in p, in r, out worldPosition);
#         }

#           public static void GetWorldToLocal_DirectionalPoint(in Vector3 worldPosition, in Quaternion worldRotation, in Vector3 positionReference, in Quaternion rotationReference, out Vector3 localPosition, out Quaternion localRotation)
#         {
#             localRotation = Quaternion.Inverse(rotationReference) * worldRotation;
#             localPosition = Quaternion.Inverse(rotationReference) * (worldPosition - positionReference);
#         }
#         public static void GetLocalToWorld_DirectionalPoint(in Vector3 localPosition, in Quaternion localRotation, in Vector3 positionReference, in Quaternion rotationReference, out Vector3 worldPosition, out Quaternion worldRotation)
#         {
#             /// I need to verify the commutativity of this code. 
#             /// I think it was ok then had a bug in a game link to this methode and thr commutative property
#             worldRotation = rotationReference * localRotation;
#             worldPosition = (rotationReference * localPosition) + (positionReference);
#         }

### DONE
##############--------------------------
### To DO

#       
#         
#         public static void GetWorldToLocal_DirectionalPoint(in Vector3 worldPosition, in Quaternion worldRotation, in Transform rootReference, out Vector3 localPosition, out Quaternion localRotation)
#         {
#             Vector3 p = rootReference.position;
#             Quaternion r = rootReference.rotation;
#             GetWorldToLocal_DirectionalPoint(in worldPosition, in worldRotation, in p, in r, out localPosition, out localRotation);
#         }
#         public static void GetLocalToWorld_DirectionalPoint(in Vector3 localPosition, in Quaternion localRotation, in Transform rootReference, out Vector3 worldPosition, out Quaternion worldRotation)
#         {
#             Vector3 p = rootReference.position;
#             Quaternion r = rootReference.rotation;
#             GetLocalToWorld_DirectionalPoint(in localPosition, in localRotation, in p, in r, out worldPosition, out worldRotation);
#         }
#     

#         

#         public static void RotateAroundPivot(Transform whatToRotate, Transform centerRotation, Quaternion rotationToApply)
#         {
#             RotateAroundPivot(whatToRotate.position, whatToRotate.rotation, centerRotation.position, rotationToApply, out Vector3 newPosition, out Quaternion newRotation);
#             whatToRotate.position = newPosition;
#             whatToRotate.rotation = newRotation;
#         }
#         public static void RotateAroundPivot(Transform whatToRotate, Vector3 centerRotation, Quaternion rotationToApply)
#         {
#             RotateAroundPivot(whatToRotate.position, whatToRotate.rotation, centerRotation, rotationToApply, out Vector3 newPosition, out Quaternion newRotation);
#             whatToRotate.position = newPosition;
#             whatToRotate.rotation = newRotation;
#         }

#         public static void RotateAroundPivot(
#             Vector3 whatToRotatePosition,
#             Quaternion whatToRotateRotation,
#             Vector3 centerRotation,
#             Quaternion rotationToApply,
#             out Vector3 newPosition,
#             out Quaternion newRotation)

#         {
#             //Rotate the right point to in aim to reconstruct the forward direction
#             Vector3 rightPoint = whatToRotatePosition + whatToRotateRotation * Vector3.right;
#             Vector3 currentPointRelocate = Eloi.RelocationUtility.RotatePointAroundPivot(whatToRotatePosition, centerRotation, rotationToApply);
#             Vector3 rightPointRelocated = Eloi.RelocationUtility.RotatePointAroundPivot(rightPoint, centerRotation, rotationToApply);
#             Vector3 centerToPointDirection = currentPointRelocate - centerRotation;
#             Vector3 pointToRightDirection = rightPointRelocated - currentPointRelocate;
#             Vector3 newForwardDirection = Vector3.Cross(pointToRightDirection, centerToPointDirection).normalized;
#             newPosition = currentPointRelocate;
#             newRotation = Quaternion.LookRotation(newForwardDirection, centerToPointDirection);

#         }


#         public static void RotateTargetAroundPointMath(
#             Vector3 postion, Quaternion rotation,
#             Vector3 center, Quaternion rotationFrom, Quaternion rotationTo,
#             out Vector3 newPosition, out Quaternion newRotation)
#         {
#             // Calculate the rotation difference (quaternion multiplication)
#             Quaternion rotationDifference = rotationTo * Quaternion.Inverse(rotationFrom);

#             // Calculate the direction from the center to the object to move
#             Vector3 direction = postion - center;

#             // Rotate the direction by the rotation difference
#             Vector3 rotatedDirection = rotationDifference * direction;

#             // Update the position of the object
#             newPosition = center + rotatedDirection;

#             // Apply the rotation difference to the object
#             newRotation = rotationDifference * rotation;

#         }

#         public static void RotateTargetAroundPointMath(Transform whatToMove, Vector3 center, Quaternion rotationFrom, Quaternion rotationTo)
#         {
#             RotateTargetAroundPointMath(
#                 whatToMove.position, whatToMove.rotation,
#                 center, rotationFrom, rotationTo,
#                 out Vector3 newPosition, out Quaternion newRotation);
#             whatToMove.position = newPosition;
#             whatToMove.rotation = newRotation;

#         }



#         public static void RotateTargetAroundPointByCreatingEmpyPoint(Transform whatToMove, Vector3 centroide, Quaternion rotationFrom, Quaternion rotationTo)
#         {
#             // THIS IS A CHEAT CODE THAT SHOULD NOT BE USED.
#             // I WILL LOOK LATER AT THE NORMAL MATH WAY TO DO IT
#             Quaternion toRotate = rotationTo * Quaternion.Inverse(rotationFrom);

#             Transform p = whatToMove.parent;
#             GameObject g = new GameObject("t");
#             Transform t = g.transform;
#             t.position = centroide;

#             whatToMove.parent = t;
#             t.rotation *= toRotate;
#             whatToMove.parent = p;
#             if (Application.isPlaying)
#                 GameObject.DestroyImmediate(g);
#             else
#                 GameObject.Destroy(g);
#         }


#         public static Quaternion GetQuaternionFromCartesianAxis(Vector3 rightDirection, Vector3 upDirection, Vector3 forwardDirection)
#         {
#             rightDirection.Normalize();
#             upDirection.Normalize();
#             forwardDirection.Normalize();
#             Matrix4x4 rotationMatrix = new Matrix4x4();
#             rotationMatrix.SetColumn(0, rightDirection);
#             rotationMatrix.SetColumn(1, upDirection);
#             rotationMatrix.SetColumn(2, forwardDirection);
#             Quaternion rotationQuaternion = rotationMatrix.rotation;
#             return rotationQuaternion;
#         }


#         public static bool IsLeftOf(Transform point, Transform reference)
#             => IsLeftOf(point.position, reference.position, reference.rotation);

#         public static bool IsRightOf(Transform point, Transform reference)
#             => IsRightOf(point.position, reference.position, reference.rotation);
#         public static bool IsAboveOf(Transform point, Transform reference)
#             => IsAboveOf(point.position, reference.position, reference.rotation);
#         public static bool IsBelowOf(Transform point, Transform reference)
#             => IsBelowOf(point.position, reference.position, reference.rotation);
#         public static bool IsFrontOf(Transform point, Transform reference)
#             => IsFrontOf(point.position, reference.position, reference.rotation);
#         public static bool IsBackOf(Transform point, Transform reference)
#             => IsBackOf(point.position, reference.position, reference.rotation);


#         public static bool IsLeftOf(Vector3 worldPoint, Vector3 anchorPoint, Quaternion anchorRotation)
#         {
#             GetWorldToLocal_Point(worldPoint, anchorPoint, anchorRotation, out Vector3 localPoint);
#             return localPoint.x < 0;
#         }
#         public static bool IsRightOf(Vector3 worldPoint, Vector3 anchorPoint, Quaternion anchorRotation)
#         {
#             GetWorldToLocal_Point(worldPoint, anchorPoint, anchorRotation, out Vector3 localPoint);
#             return localPoint.x > 0;
#         }
#         public static bool IsAboveOf(Vector3 worldPoint, Vector3 anchorPoint, Quaternion anchorRotation)
#         {
#             GetWorldToLocal_Point(worldPoint, anchorPoint, anchorRotation, out Vector3 localPoint);
#             return localPoint.y > 0;
#         }
#         public static bool IsBelowOf(Vector3 worldPoint, Vector3 anchorPoint, Quaternion anchorRotation)
#         {
#             GetWorldToLocal_Point(worldPoint, anchorPoint, anchorRotation, out Vector3 localPoint);
#             return localPoint.y < 0;
#         }

#         public static bool IsFrontOf(Vector3 worldPoint, Vector3 anchorPoint, Quaternion anchorRotation)
#         {
#             GetWorldToLocal_Point(worldPoint, anchorPoint, anchorRotation, out Vector3 localPoint);
#             return localPoint.z > 0;
#         }
#         public static bool IsBackOf(Vector3 worldPoint, Vector3 anchorPoint, Quaternion anchorRotation)
#         {
#             GetWorldToLocal_Point(worldPoint, anchorPoint, anchorRotation, out Vector3 localPoint);
#             return localPoint.z < 0;
#         }

#     }
# }
