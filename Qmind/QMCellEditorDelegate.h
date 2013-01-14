/**
 * Tae Won Ha
 * http://qvacua.com
 * https://bitbucket.org/qvacua
 *
 * See LICENSE
 */

@class QMCell;

@protocol QMCellEditorDelegate

@required
- (void)editingEndedWithString:(NSAttributedString *)newAttrStr forCell:(QMCell *)editedCell byChar:(unichar)character;
- (void)editingCancelledWithString:(NSAttributedString *)newAttrStr forCell:(QMCell *)editedCell;

@end
