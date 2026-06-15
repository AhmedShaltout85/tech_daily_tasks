# Update Complaints Task Note

## Goal
Change the taskNote field in the create task bottom sheet from a read-only text to an editable TextField, pre-filled with `${complaint.empMobile} - ${complaint.empName} - سوفتير`.

## File
`tasks_app/lib/screens/complaints/manage_complmaints_screen.dart`

## Changes

1. **Add `TextEditingController`** in `_showCreateTaskBottomSheet` (line ~284):
   ```dart
   final notesController = TextEditingController(
     text: '${complaint.empMobile} - ${complaint.empName} - سوفتير',
   );
   ```

2. **Pass `notesController`** to `_buildCreateTaskContent` as a new parameter.

3. **Replace `_buildReadOnlyField` for ملاحظات** (line 374-375) with a `TextField`:
   - Label: `ملاحظات`
   - Uses `notesController`
   - Styled to match the bottom sheet design

4. **Update `_submitCreateTask`** signature to accept `String taskNote` parameter.

5. **Use `taskNote`** in `DailyTaskModel` creation (line 595) instead of the hardcoded string.

6. **Dispose `notesController`** when bottom sheet closes.
