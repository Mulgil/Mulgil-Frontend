part of 'course_form_sheet.dart';

extension on _CourseFormSheetState {
  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '과목 추가',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: '과목명'),
            onChanged: (_) => _clearError(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _professorCtrl,
            decoration: const InputDecoration(labelText: '교수님 (선택)'),
          ),
          const SizedBox(height: 14),
          const Text(
            '요일',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: List.generate(7, (i) => i + 1)
                .map(
                  (wd) => ChoiceChip(
                    label: Text(TimetableSlot.weekdayLabels[wd - 1]),
                    selected: _timesByWeekday.containsKey(wd),
                    onSelected: (sel) => _toggleWeekday(wd, sel),
                  ),
                )
                .toList(),
          ),
          if (_timesByWeekday.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              '수업 시간',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            ..._timeEntries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        TimetableSlot.weekdayLabels[entry.key - 1],
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        key: ValueKey('course-time-start-${entry.key}'),
                        onPressed: () => _pickTime(entry.key, isStart: true),
                        child: Text('시작 ${_formatTime(entry.value.start)}'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        key: ValueKey('course-time-end-${entry.key}'),
                        onPressed: () => _pickTime(entry.key, isStart: false),
                        child: Text('종료 ${_formatTime(entry.value.end)}'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_errorText != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 16,
                  color: AppColors.coral,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorText!,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.coral,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          MulgilButton(
            label: _submitting ? '추가 중...' : '추가',
            onTap: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
